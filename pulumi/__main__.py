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


# import pulumi
# import pulumi_gcp as gcp
# import pulumi_docker as docker
# import time
# from pulumi import ResourceOptions

# # Configs
# config = pulumi.Config()
# project = config.require("project")
# region = config.require("region")

# # Create GCP provider
# gcp_provider = gcp.Provider(
#     "gcp-provider",
#     project=project,
#     region=region
# )

# # Helper: Wait for IAM propagation by sleeping and returning ResourceOptions
# def wait_for_iam_propagation(resource: pulumi.Resource):
#     """Wait 60 seconds after creating a resource to allow IAM propagation"""
#     time.sleep(60)
#     return ResourceOptions(
#         provider=gcp_provider,
#         depends_on=[resource]
#     )

# # Enable required APIs
# services = [
#     "run.googleapis.com",
#     "artifactregistry.googleapis.com",
#     "cloudbuild.googleapis.com",
#     "iam.googleapis.com",
#     "serviceusage.googleapis.com",
#     "cloudresourcemanager.googleapis.com"
# ]

# enabled_apis = []
# iam_api_resource = None  # Track separately

# for service in services:
#     resource = gcp.projects.Service(
#         f"enable-{service}",
#         service=service,
#         project=project,
#         disable_on_destroy=False,
#         opts=ResourceOptions(provider=gcp_provider)
#     )
#     enabled_apis.append(resource)

#     if service == "iam.googleapis.com":
#         iam_api_resource = resource

# if iam_api_resource is None:
#     raise Exception("iam.googleapis.com API was not found in enabled_apis.")


# # Create Artifact Registry repository
# repo = gcp.artifactregistry.Repository(
#     "my-nodejs-app-repo",
#     format="DOCKER",
#     location=region,
#     repository_id="my-nodejs-app-repo",
#     project=project,
#     opts=ResourceOptions(
#         provider=gcp_provider,
#         depends_on=enabled_apis,
#         import_=f"projects/{project}/locations/{region}/repositories/my-nodejs-app-repo"
#     ),
#     labels={}  # ✅ correct key to avoid import mismatch error
# )


# # Deployer service account email (used by GitHub Actions)
# deployer_sa_email = "pulumi-dev-deployer@weather-app2-460914.iam.gserviceaccount.com"

# # Grant roles to deployer service account
# required_roles = [
#     ("artifactregistry-writer", "roles/artifactregistry.writer"),
#     ("run-admin", "roles/run.admin"),
#     ("sa-user", "roles/iam.serviceAccountUser"),
#     ("cloudbuild-editor", "roles/cloudbuild.builds.editor")
# ]

# role_bindings = []
# for role_name, role in required_roles:
#     binding = gcp.projects.IAMMember(
#         f"grant-{role_name}-to-deployer",
#         project=project,
#         role=role,
#         member=f"serviceAccount:{deployer_sa_email}",
#         opts=wait_for_iam_propagation(iam_api_resource)
#     )
#     role_bindings.append(binding)

# # Create Cloud Run service account
# cloud_run_sa = gcp.serviceaccount.Account(
#     "cloud-run-sa",
#     account_id="cloud-run-sa",
#     display_name="Cloud Run Service Account",
#     project=project,
#     opts=ResourceOptions(
#         provider=gcp_provider,
#         depends_on=role_bindings
#     )
# )

# # Grant roles to Cloud Run service account
# cloud_run_roles = [
#     ("run-invoker", "roles/run.invoker"),
#     ("logging-log-writer", "roles/logging.logWriter"),
#     ("metric-writer", "roles/monitoring.metricWriter")
# ]

# for role_name, role in cloud_run_roles:
#     gcp.projects.IAMMember(
#         f"grant-{role_name}-to-cloudrun-sa",
#         project=project,
#         role=role,
#         member=cloud_run_sa.email.apply(lambda email: f"serviceAccount:{email}"),
#         opts=wait_for_iam_propagation(cloud_run_sa)
#     )

# # Define Docker image URL for Artifact Registry
# image_url = pulumi.Output.concat(
#     region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
# )

# # Build and push Docker image
# app_image = docker.Image(
#     "nodejs-app-image",
#     image_name=image_url,
#     build=docker.DockerBuildArgs(
#         context="../",  # Adjust path to your Node.js app root
#         dockerfile="../Dockerfile",  # Explicit path to Dockerfile
#         platform="linux/amd64",  # Explicit platform
#         args={"NODE_ENV": "production"}
#     ),
#     registry=docker.RegistryArgs(
#     server=f"{region}-docker.pkg.dev",
#     username="_json_key"
#     #password=config.require_secret("gcp:credentials")
# 	),
#     opts=ResourceOptions(
#         depends_on=[repo, *role_bindings]
#     )
# )


# # Deploy Cloud Run service - SIMPLIFIED AND FIXED
# cloud_run_service = gcp.cloudrunv2.Service(
#     "nodejs-cloudrun-service",
#     name="nodejs-cloudrun-service",
#     location=region,
#     project=project,
#     # Use JSON-compatible configuration
#     template=gcp.cloudrunv2.ServiceTemplateArgs(
#         containers=[gcp.cloudrunv2.ServiceTemplateContainerArgs(
#             image=app_image.image_name,
#             envs=[gcp.cloudrunv2.ServiceTemplateContainerEnvArgs(
#                 name="PORT",
#                 value="8080"
#             )]
#         )],
#         service_account=cloud_run_sa.email
#     ),
#     traffics=[gcp.cloudrunv2.ServiceTrafficArgs(
#         type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
#         percent=100
#     )],
#     opts=ResourceOptions(provider=gcp_provider)
# )


# # Outputs
# pulumi.export("cloud_run_url", cloud_run_service.uri)
# pulumi.export("docker_image_url", image_url)
# pulumi.export("service_account_email", cloud_run_sa.email)
# pulumi.export("artifact_registry_url", repo.name)



# # Last worked
# #------------------------------
# import pulumi
# import pulumi_gcp as gcp
# import pulumi_docker as docker
# from pulumi import ResourceOptions

# # Configs
# config = pulumi.Config()
# project = config.require("project")
# region = config.require("region")

# # Create GCP provider
# gcp_provider = gcp.Provider(
#     "gcp-provider",
#     project=project,
#     region=region
# )

# # Enable required APIs
# services = [
#     "run.googleapis.com",
#     "artifactregistry.googleapis.com",
#     "cloudbuild.googleapis.com",
#     "iam.googleapis.com",
#     "serviceusage.googleapis.com",
#     "cloudresourcemanager.googleapis.com"
# ]

# enabled_apis = []
# for service in services:
#     resource = gcp.projects.Service(
#         f"enable-{service}",
#         service=service,
#         project=project,
#         disable_on_destroy=False,
#         opts=ResourceOptions(provider=gcp_provider)
#     )
#     enabled_apis.append(resource)

# # FIXED: Artifact Registry with proper import configuration
# repo = gcp.artifactregistry.Repository(
#     "my-nodejs-app-repo",
#     format="DOCKER",
#     location=region,
#     repository_id="my-nodejs-app-repo",
#     project=project,
#     opts=ResourceOptions(
#         provider=gcp_provider,
#         depends_on=enabled_apis,
#         import_=f"projects/{project}/locations/{region}/repositories/my-nodejs-app-repo"
#     ),
#     labels={}  # ✅ correct key to avoid import mismatch error
# )

# # Deployer service account email
# deployer_sa_email = "pulumi-dev-deployer@weather-app2-460914.iam.gserviceaccount.com"

# # Grant roles to deployer service account
# required_roles = [
#     ("artifactregistry-writer", "roles/artifactregistry.writer"),
#     ("run-admin", "roles/run.admin"),
#     ("sa-user", "roles/iam.serviceAccountUser"),
#     ("cloudbuild-editor", "roles/cloudbuild.builds.editor")
# ]

# for role_name, role in required_roles:
#     gcp.projects.IAMMember(
#         f"grant-{role_name}-to-deployer",
#         project=project,
#         role=role,
#         member=f"serviceAccount:{deployer_sa_email}",
#         opts=ResourceOptions(provider=gcp_provider)
#     )


# # FIX: Service account creation
# cloud_run_sa = gcp.serviceaccount.Account(
#     "cloud-run-sa",
#     account_id="cloud-run-sa",  # Ensure this matches your naming
#     display_name="Cloud Run Service Account",
#     project=project,
#     opts=ResourceOptions(
#         provider=gcp_provider,
#         # Add explicit dependency on enabled APIs
#         depends_on=enabled_apis
#     )
# )

# # FIXED: IAM bindings with explicit dependency on service account
# cloud_run_roles = [
#     ("run-invoker", "roles/run.invoker"),
#     ("logging-log-writer", "roles/logging.logWriter"),
#     ("metric-writer", "roles/monitoring.metricWriter")
# ]


# # FIX: IAM bindings with stronger dependency
# for role_name, role in cloud_run_roles:
#     gcp.projects.IAMMember(
#         f"grant-{role_name}-to-cloudrun-sa",
#         project=project,
#         role=role,
#         member=cloud_run_sa.email.apply(lambda email: f"serviceAccount:{email}"),
#         opts=ResourceOptions(
#             provider=gcp_provider,
#             # Add explicit dependency on service account creation
#             depends_on=[cloud_run_sa]
#         )
#     )


# # Docker image configuration
# image_url = pulumi.Output.concat(
#     region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
# )

# app_image = docker.Image(
#     "nodejs-app-image",
#     image_name=image_url,
#     build=docker.DockerBuildArgs(
#         context="../",
#         dockerfile="../Dockerfile",
#         platform="linux/amd64",
#         args={"NODE_ENV": "production"}
#     ),
#     registry=docker.RegistryArgs(
#         server=f"{region}-docker.pkg.dev",
#         username="_json_key",
#         password=config.require_secret("gcpServiceAccountKey")  # 🔑 Must be set
#     ),
#     opts=ResourceOptions(provider=gcp_provider)
# )

# # Cloud Run service
# cloud_run_service = gcp.cloudrunv2.Service(
#     "nodejs-cloudrun-service",
#     name="nodejs-cloudrun-service",
#     location=region,
#     project=project,
#     template=gcp.cloudrunv2.ServiceTemplateArgs(
#         containers=[gcp.cloudrunv2.ServiceTemplateContainerArgs(
#             image=app_image.image_name,
#             envs=[gcp.cloudrunv2.ServiceTemplateContainerEnvArgs(
#                 name="PORT",
#                 value="8080"
#             )]
#         )],
#         service_account=cloud_run_sa.email
#     ),
#     traffics=[gcp.cloudrunv2.ServiceTrafficArgs(
#         type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
#         percent=100
#     )],
#     opts=ResourceOptions(provider=gcp_provider)
# )

# # Outputs
# pulumi.export("cloud_run_url", cloud_run_service.uri)
# pulumi.export("docker_image_url", image_url)
# pulumi.export("service_account_email", cloud_run_sa.email)
# pulumi.export("artifact_registry_url", repo.name)


import pulumi
import pulumi_gcp as gcp
import pulumi_docker as docker
from pulumi import ResourceOptions

# Configs
config = pulumi.Config()
project = config.require("project")
region = config.require("region")
gcp_service_account_key = config.require_secret("gcpServiceAccountKey")

# Create GCP provider - SIMPLIFIED
gcp_provider = gcp.Provider(
    "gcp-provider",
    project=project,
    region=region,
    opts=ResourceOptions(ignore_changes=["project"])
)

# Deployer service account email
deployer_sa_email = "pulumi-dev-deployer@weather-app2-460914.iam.gserviceaccount.com"

# Required IAM roles for deployer service account
required_roles = [
    ("serviceusage-admin", "roles/serviceusage.serviceUsageAdmin"),
    ("artifactregistry-admin", "roles/artifactregistry.admin"),
    ("artifactregistry-writer", "roles/artifactregistry.writer"),  # ADD THIS
    ("run-admin", "roles/run.admin"),
    ("sa-user", "roles/iam.serviceAccountUser"),
    ("cloudbuild-editor", "roles/cloudbuild.builds.editor"),
    ("resourcemanager-projectIamAdmin", "roles/resourcemanager.projectIamAdmin")
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

# Enable required APIs - DEPENDS ON IAM GRANTS
services = [
    "serviceusage.googleapis.com",  # Must be first
    "compute.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
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

# Artifact Registry - DEPENDS ON ENABLED APIS
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

# Service account for Cloud Run - DEPENDS ON ENABLED APIS
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

# Docker image configuration
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
        depends_on=[repo]  # Wait for repository creation
    )
)

# Cloud Run service
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

# Outputs
pulumi.export("cloud_run_url", cloud_run_service.uri)
pulumi.export("docker_image_url", image_url)
pulumi.export("service_account_email", cloud_run_sa.email)
pulumi.export("artifact_registry_url", repo.name)


# Deploy Cloud Run service
# cloud_run_service = gcp.cloudrunv2.Service(
#     "nodejs-cloudrun-service",
#     name="nodejs-cloudrun-service",
#     location=region,
#     project=project,
#     template=gcp.cloudrunv2.ServiceTemplateArgs(
#         containers=[
#             gcp.cloudrunv2.ServiceTemplateContainerArgs(
#                 image=app_image.image_name,
#                 ports=[
#                     gcp.cloudrunv2.ServiceTemplateContainerPortsArgs(
#                         container_port=8080
#                     )
#                 ],
#                 envs=[
#                     gcp.cloudrunv2.ServiceTemplateContainerEnvArgs(
#                         name="NODE_ENV", value="production"
#                     )
#                 ]
#             )
#         ],
#         service_account=cloud_run_sa.email
#     ),
#     traffics=[
#         gcp.cloudrunv2.ServiceTrafficArgs(
#             type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST",
#             percent=100
#         )
#     ],
#     opts=ResourceOptions(
#         provider=gcp_provider,
#         depends_on=[app_image, cloud_run_sa]
#     )
# )