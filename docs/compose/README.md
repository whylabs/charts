# Guardrails Application Deployment

## Prerequisites

Before you start, make sure you have Docker and Docker Compose installed on your
system. You will also need to clone the repository containing the Docker Compose
file and related configuration files.

## Configuration

### Environment Variables

Set the necessary environment variables before starting the application:

- `CONTAINER_PASSWORD`: Password used internally by containers. Set this in your environment or directly in the Docker Compose file.
- `WHYLABS_API_KEY`: API key for WhyLabs integration.
- `AUTO_PULL_WHYLABS_POLICY_MODEL_IDS`: A csv value of the model ids that you want automatically sync the WhyLabs platform metric policy
  from.

Example:

```bash
export CONTAINER_PASSWORD=yourpassword
export WHYLABS_API_KEY=yourapikey

# Optional
export AUTO_PULL_WHYLABS_POLICY_MODEL_IDS=model-1
```

### Logging into GitLab Container Registry

Before pulling images from the private GitLab container registry, you must log
in using the credentials provided by WhyLabs. 

1. Open your terminal.
2. Execute the following command:

```bash
docker login registry.gitlab.com -u "${username}" -p "${password}"
```

### Adjusting Replicas

To change the number of replicas for the guardrails service:

1. Open the `compose.yaml` file.

1. Find the guardrails service section.

1. Modify the replicas value under the deploy key.

Example:

```yaml
deploy:
  replicas: 5  # Change this number as needed
```

### Adjusting Resources

To modify the CPU and memory limits for the guardrails or nginx services:

1. Navigate to the resources section under the respective service in the
`compose.yaml` file.

1. Adjust the cpus and memory under both limits and reservations.

Example for Guardrails:

```yaml
resources:
  limits:
    cpus: '6.0'  # From 4.0 to 6.0 for example
    memory: 8192M  # From 6144M to 8192M for example
```

### Updating the Image and Tag

To update the Docker image used by the guardrails service:

1. Locate the image key under the guardrails service in the
`compose.yaml` file.

1. Update the image name and tag.

Example:

```yaml
image: registry.gitlab.com/whylabs/whylogs-container:newtag
```
## Running the Application

To run the application, use the following command from the directory containing
your `compose.yaml` file.

> :warning: It is important to execute `docker compose` commands from this
directory, the one containing the `compose.yaml` file. The configuration expects
the `nginx.conf` to be a sibling to the `compose.yaml` file.

```bash
docker compose up -d
```

This will start all services defined in the Docker Compose file.

### Stopping the Application

To stop all services, run:

```bash
docker compose down
```

### Monitoring and Logs

To view the logs for a specific service, use:

```bash
docker compose logs -f guardrails
```

Replace guardrails with nginx to view logs for the NGINX service.
