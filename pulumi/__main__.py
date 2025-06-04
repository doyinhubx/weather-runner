# """A Google Cloud Python Pulumi program"""

# import pulumi
# from pulumi_gcp import storage

# # Create a GCP resource (Storage Bucket)
# bucket = storage.Bucket('my-bucket', location="US")

# # Export the DNS name of the bucket
# pulumi.export('bucket_name', bucket.url)



import pulumi
import pulumi_gcp as gcp

# Configs
config = pulumi.Config()
project = config.require("project")
region = config.require("region")

# Enable required APIs
#----------------------------------------------------
services = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com"
]

for service in services:
    gcp.projects.Service(
        f"enable-{service}",
        service=service,
        project=project,  # Add project parameter
        disable_on_destroy=False
    )

# # Create Artifact Registry repo for container image (First RUN)
#----------------------------------------------------
# repo = gcp.artifactregistry.Repository(
#     "my-nodejs-app-repo",
#     format="DOCKER",
#     location=region,
#     repository_id="my-nodejs-app-repo",
#     project=project  # Add project parameter
# )

repo = gcp.artifactregistry.Repository.get(
    "my-nodejs-app-repo",
    id=f"projects/{project}/locations/{region}/repositories/my-nodejs-app-repo"
)


# # Create a service account for Cloud Run (First RUN)
#----------------------------------------------------
# cloud_run_sa = gcp.serviceaccount.Account(
#     "cloud-run-sa",
#     account_id="cloud-run-sa",
#     display_name="Cloud Run Service Account",
#     project=project  # Add project parameter
# )

cloud_run_sa = gcp.serviceaccount.Account.get(
    "cloud-run-sa",
    id="projects/{}/serviceAccounts/cloud-run-sa@{}.iam.gserviceaccount.com".format(project, project),
)


# Grant roles to the service account
#----------------------------------------------------
run_invoker_binding = gcp.projects.IAMMember(
    "cloud-run-invoker",
    project=project,  # This is the critical missing parameter
    role="roles/run.invoker",
    member=cloud_run_sa.email.apply(lambda email: f"serviceAccount:{email}")
)

# Deploy Cloud Run service from container image
#----------------------------------------------------
image_url = pulumi.Output.concat(
    region, "-docker.pkg.dev/", project, "/my-nodejs-app-repo/nodejs-app"
)

import pulumi_docker as docker

# Define the Docker image
app_image = docker.Image(
    "nodejs-app-image",
    image_name=image_url,
    build=docker.DockerBuildArgs(context="..")  # go to weather-app/
)

cloud_run_service = gcp.cloudrunv2.Service(
    "nodejs-cloudrun-service",
    name="nodejs-cloudrun-service",
    location=region,
    project=project,  # Add project parameter
    template=gcp.cloudrunv2.ServiceTemplateArgs(
        containers=[
            gcp.cloudrunv2.ServiceTemplateContainerArgs(
                #image=image_url,
                image=app_image.image_name,  # Use built image
            )
        ],
        service_account=cloud_run_sa.email,
    ),
    traffics=[gcp.cloudrunv2.ServiceTrafficArgs(
        type="TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST", percent=100)]
)

# Export outputs
#----------------------------------------------------
pulumi.export("cloud_run_url", cloud_run_service.uri)
pulumi.export("docker_image_url", image_url)
pulumi.export("service_account_email", cloud_run_sa.email)