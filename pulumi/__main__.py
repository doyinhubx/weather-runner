# Default Pulumi Project
#-------------------------------------------------------------------
# """A Google Cloud Python Pulumi program"""

# import pulumi
# from pulumi_gcp import storage

# # Create a GCP resource (Storage Bucket)
# bucket = storage.Bucket('my-bucket', location="US")

# # Export the DNS name of the bucket
# pulumi.export('bucket_name', bucket.url)



# STAGE 1: Import Libraries with neccessary Configurations
#-------------------------------------------------------------------
import pulumi
import pulumi_gcp as gcp
import pulumi_docker as docker
from pulumi import ResourceOptions

# Configs
config = pulumi.Config()
project = config.require("project")
region = config.require("region")
gcp_service_account_key = config.require_secret("gcpServiceAccountKey")

# Create GCP provider 
gcp_provider = gcp.Provider(
    "gcp-provider",
    project=project,
    region=region,
    opts=ResourceOptions(ignore_changes=["project"])
)

# Add at the top of your Pulumi code
admin_sa_email = "admin-account-sa@weather-app2-460914.gserviceaccount.com"  


# STAGE 1: Enable required APIs 
#-------------------------------------------------------------------
services = [
    "serviceusage.googleapis.com",  # Must be first
    "compute.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
    "storage.googleapis.com"
]

enabled_apis = []
for service in services:
    resource = gcp.projects.Service(
        f"enable-{service}",
        service=service,
        project=project,
        disable_on_destroy=False,
        opts=ResourceOptions(
            provider=gcp_provider,
            depends_on=iam_grants  # Critical dependency
        )
    )
    enabled_apis.append(resource)


# STAGE 3: Configure a Deployer Service Account
#-------------------------------------------------------------------
# Deployer service account email
deployer_sa_email = "pulumi-dev-deployer@weather-app2-460914.iam.gserviceaccount.com"

# Required IAM roles for deployer service account
required_roles = [
    ("serviceusage-admin", "roles/serviceusage.serviceUsageAdmin"),
    ("artifactregistry-admin", "roles/artifactregistry.admin"),
    ("artifactregistry-writer", "roles/artifactregistry.writer"),  
    ("run-admin", "roles/run.admin"),
    ("sa-user", "roles/iam.serviceAccountUser"),
    ("sa-token-creator", "roles/iam.serviceAccountTokenCreator"), 
    ("cloudbuild-editor", "roles/cloudbuild.builds.editor"),
    ("resourcemanager-projectIamAdmin", "roles/resourcemanager.projectIamAdmin"),
    ("storage-object-admin", "roles/storage.objectAdmin"),
    ("artifactregistry-reader", "roles/artifactregistry.reader"),
	("project-viewer", "roles/viewer"),
	("run-viewer", "roles/run.viewer"),  
]

# Grant roles to deployer service account - MUST BE FIRST
iam_grants = []
for role_name, role in required_roles:
    grant = gcp.projects.IAMMember(
        f"grant-{role_name}-to-deployer",
        project=project,
        role=role,
        member=f"serviceAccount:{deployer_sa_email}",
        opts=ResourceOptions(provider=gcp_provider)
    )
    iam_grants.append(grant)


# STAGE 4: Configure Artifact Registry - DEPENDS ON ENABLED APIS
#-------------------------------------------------------------------
repo = gcp.artifactregistry.Repository(
    "my-nodejs-app-repo",
    format="DOCKER",
    location=region,
    repository_id="my-nodejs-app-repo",
    project=project,
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=enabled_apis
    ),
    labels={}
)

# Add explicit repository IAM binding for deployer account
repo_iam = gcp.artifactregistry.RepositoryIamMember(
    "deployer-repo-upload-access",
    repository=repo.name,
    location=region,
    role="roles/artifactregistry.writer",
    member=f"serviceAccount:{deployer_sa_email}",
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=[repo]  # Must exist before applying IAM
    )
)

# Add after repository creation
admin_repo_iam = gcp.artifactregistry.RepositoryIamMember(
    "admin-repo-access",
    repository=repo.name,
    location=region,
    role="roles/artifactregistry.admin",  # Full access
    member=f"serviceAccount:{admin_sa_email}",
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=[repo]
    )
)

# STAGE 5: Service account for Cloud Run 
#-------------------------------------------------------------------
cloud_run_sa = gcp.serviceaccount.Account(
    "cloud-run-sa",
    account_id="cloud-run-sa",
    display_name="Cloud Run Service Account",
    project=project,
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=enabled_apis
    )
)

# IAM bindings for Cloud Run SA
cloud_run_roles = [
    ("run-invoker", "roles/run.invoker"),
    ("logging-log-writer", "roles/logging.logWriter"),
    ("metric-writer", "roles/monitoring.metricWriter")
]

for role_name, role in cloud_run_roles:
    gcp.projects.IAMMember(
        f"grant-{role_name}-to-cloudrun-sa",
        project=project,
        role=role,
        member=cloud_run_sa.email.apply(lambda email: f"serviceAccount:{email}"),
        opts=ResourceOptions(
            provider=gcp_provider,
            depends_on=[cloud_run_sa]  # Essential dependency
        )
    )

# STAGE 6: Docker image configuration
#-------------------------------------------------------------------
image_url = pulumi.Output.concat(
    region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
)

app_image = docker.Image(
    "nodejs-app-image",
    image_name=image_url,
    build=docker.DockerBuildArgs(
        context="../",
        dockerfile="../Dockerfile",
        platform="linux/amd64",
        args={"NODE_ENV": "production"}
    ),
    registry=docker.RegistryArgs(
        server=f"{region}-docker.pkg.dev",
        username="_json_key",
        password=gcp_service_account_key  # Use directly
    ),
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=[repo, repo_iam]  # Wait for repository creation and IAM binding
    )
)

# STAGE 7: Cloud Run service
#-------------------------------------------------------------------
cloud_run_service = gcp.cloudrunv2.Service(
    "nodejs-cloudrun-service",
    name="nodejs-cloudrun-service",
    location=region,
    project=project,
    template=gcp.cloudrunv2.ServiceTemplateArgs(
        containers=[gcp.cloudrunv2.ServiceTemplateContainerArgs(
            image=app_image.image_name,
            envs=[gcp.cloudrunv2.ServiceTemplateContainerEnvArgs(
                name="PORT",
                value="8080"
            )]
        )],
        service_account=cloud_run_sa.email
    ),
    traffics=[gcp.cloudrunv2.ServiceTrafficArgs(
        type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
        percent=100
    )],
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=[cloud_run_sa, app_image]  # Wait for dependencies
    )
)

# STAGE 8: Outputs
#-------------------------------------------------------------------
pulumi.export("cloud_run_url", cloud_run_service.uri)
pulumi.export("docker_image_url", image_url)
pulumi.export("service_account_email", cloud_run_sa.email)
pulumi.export("artifact_registry_url", repo.name)

