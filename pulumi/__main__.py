# """A Google Cloud Python Pulumi program"""

# import pulumi
# from pulumi_gcp import storage

# # Create a GCP resource (Storage Bucket)
# bucket = storage.Bucket('my-bucket', location="US")

# # Export the DNS name of the bucket
# pulumi.export('bucket_name', bucket.url)



# import pulumi
# import pulumi_gcp as gcp

# # Configs
# config = pulumi.Config()
# project = config.require("project")
# region = config.require("region")

# # Enable required APIs
# #----------------------------------------------------
# services = [
#     "run.googleapis.com",
#     "artifactregistry.googleapis.com",
#     "cloudbuild.googleapis.com",
#     "iam.googleapis.com",
#     "serviceusage.googleapis.com"
# ]

# for service in services:
#     gcp.projects.Service(
#         f"enable-{service}",
#         service=service,
#         project=project,  # Add project parameter
#         disable_on_destroy=False
#     )

# # # Create Artifact Registry repo for container image (First RUN)
# #----------------------------------------------------
# # repo = gcp.artifactregistry.Repository(
# #     "my-nodejs-app-repo",
# #     format="DOCKER",
# #     location=region,
# #     repository_id="my-nodejs-app-repo",
# #     project=project  # Add project parameter
# # )

# repo = gcp.artifactregistry.Repository.get(
#     "my-nodejs-app-repo",
#     id=f"projects/{project}/locations/{region}/repositories/my-nodejs-app-repo"
# )


# # # Create a service account for Cloud Run (First RUN)
# #----------------------------------------------------
# # cloud_run_sa = gcp.serviceaccount.Account(
# #     "cloud-run-sa",
# #     account_id="cloud-run-sa",
# #     display_name="Cloud Run Service Account",
# #     project=project  # Add project parameter
# # )

# cloud_run_sa = gcp.serviceaccount.Account.get(
#     "cloud-run-sa",
#     id="projects/{}/serviceAccounts/cloud-run-sa@{}.iam.gserviceaccount.com".format(project, project),
# )


# # Grant roles to the service account
# #----------------------------------------------------
# run_invoker_binding = gcp.projects.IAMMember(
#     "cloud-run-invoker",
#     project=project,  # This is the critical missing parameter
#     role="roles/run.invoker",
#     member=cloud_run_sa.email.apply(lambda email: f"serviceAccount:{email}")
# )

# # Deploy Cloud Run service from container image
# #----------------------------------------------------
# image_url = pulumi.Output.concat(
#     region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
# )

# import pulumi_docker as docker

# # Define the Docker image
# app_image = docker.Image(
#     "nodejs-app-image",
#     image_name=image_url,
#     build=docker.DockerBuildArgs(context="..")  # go to weather-app/
# )

# cloud_run_service = gcp.cloudrunv2.Service(
#     "nodejs-cloudrun-service",
#     name="nodejs-cloudrun-service",
#     location=region,
#     project=project,  # Add project parameter
#     template=gcp.cloudrunv2.ServiceTemplateArgs(
#         containers=[
#             gcp.cloudrunv2.ServiceTemplateContainerArgs(
#                 #image=image_url,
#                 image=app_image.image_name,  # Use built image
#             )
#         ],
#         service_account=cloud_run_sa.email,
#     ),
#     traffics=[gcp.cloudrunv2.ServiceTrafficArgs(
#         type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent=100)]
# )

# # Export outputs
# #----------------------------------------------------
# pulumi.export("cloud_run_url", cloud_run_service.uri)
# pulumi.export("docker_image_url", image_url)
# pulumi.export("service_account_email", cloud_run_sa.email)


import pulumi
import pulumi_gcp as gcp
import pulumi_docker as docker
import time
from pulumi import ResourceOptions

# Configs
config = pulumi.Config()
project = config.require("project")
region = config.require("region")

# Create GCP provider with explicit credentials
gcp_provider = gcp.Provider(
    "gcp-provider",
    project=project,
    region=region
    #credentials=config.require_secret("gcp:credentials")
)

def wait_for_iam_propagation(resource_name):
    """Wait 60 seconds after creating a resource to allow IAM propagation"""
    time.sleep(60)
    return ResourceOptions(
        provider=gcp_provider,
        depends_on=[resource_name]
    )

# Enable required APIs
services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com"
]

enabled_apis = []
for service in services:
    enabled_api = gcp.projects.Service(
        f"enable-{service}",
        service=service,
        project=project,
        disable_on_destroy=False,
        opts=ResourceOptions(provider=gcp_provider)
    )
    enabled_apis.append(enabled_api)

# Create Artifact Registry repository
repo = gcp.artifactregistry.Repository(
    "my-nodejs-app-repo",
    format="DOCKER",
    location=region,
    repository_id="my-nodejs-app-repo",
    project=project,
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=enabled_apis
    )
)

# Define deployer service account (from GitHub Actions)
deployer_sa_email = "pulumi-dev-deployer@weather-app2-460914.iam.gserviceaccount.com"

# Grant necessary permissions to deployer SA
required_roles = [
    ("artifactregistry-writer", "roles/artifactregistry.writer"),
    ("run-admin", "roles/run.admin"),
    ("sa-user", "roles/iam.serviceAccountUser"),
    ("cloudbuild-editor", "roles/cloudbuild.builds.editor")
]

role_bindings = []
for role_name, role in required_roles:
    binding = gcp.projects.IAMMember(
        f"grant-{role_name}-to-deployer",
        project=project,
        role=role,
        member=f"serviceAccount:{deployer_sa_email}",
        opts=wait_for_iam_propagation("enable-iam.googleapis.com")
    )
    role_bindings.append(binding)

# Create Cloud Run service account
cloud_run_sa = gcp.serviceaccount.Account(
    "cloud-run-sa",
    account_id="cloud-run-sa",
    display_name="Cloud Run Service Account",
    project=project,
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=role_bindings
    )
)

# Grant Cloud Run SA necessary permissions
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
        opts=wait_for_iam_propagation(cloud_run_sa)
    )

# Configure Docker image
image_url = pulumi.Output.concat(
    region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
)

# Build and push Docker image with proper authentication
app_image = docker.Image(
    "nodejs-app-image",
    image_name=image_url,
    build=docker.DockerBuildArgs(
        context="../",  # Points to your application root
        dockerfile="Dockerfile",
        args={
            "NODE_ENV": "production"
        }
    ),
    registry=docker.ImageRegistryArgs(
        server=f"{region}-docker.pkg.dev",
        username="_json_key",
        password=config.require_secret("gcp:credentials")
    ),
    opts=ResourceOptions(
        depends_on=[repo, *role_bindings]
    )
)

# Deploy Cloud Run service
cloud_run_service = gcp.cloudrunv2.Service(
    "nodejs-cloudrun-service",
    name="nodejs-cloudrun-service",
    location=region,
    project=project,
    template=gcp.cloudrunv2.ServiceTemplateArgs(
        containers=[
            gcp.cloudrunv2.ServiceTemplateContainerArgs(
                image=app_image.image_name,
                ports=[gcp.cloudrunv2.ServiceTemplateContainerPortArgs(
                    container_port=8080  # Must match your app's port
                )],
                envs=[
                    gcp.cloudrunv2.ServiceTemplateContainerEnvArgs(
                        name="NODE_ENV",
                        value="production"
                    )
                ]
            )
        ],
        service_account=cloud_run_sa.email,
    ),
    traffics=[
        gcp.cloudrunv2.ServiceTrafficArgs(
            type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
            percent=100
        )
    ],
    opts=ResourceOptions(
        provider=gcp_provider,
        depends_on=[app_image, cloud_run_sa]
    )
)

# Export important URLs and identifiers
pulumi.export("cloud_run_url", cloud_run_service.uri)
pulumi.export("docker_image_url", image_url)
pulumi.export("service_account_email", cloud_run_sa.email)
pulumi.export("artifact_registry_url", repo.name)