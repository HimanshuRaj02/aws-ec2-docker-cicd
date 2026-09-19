# AWS EC2 + Docker + GitHub Actions CI/CD

![Build and deploy](https://github.com/HimanshuRaj02/aws-ec2-docker-cicd/actions/workflows/deploy.yml/badge.svg)

A small website that is deployed to an AWS EC2 server automatically. Every push to `main` builds a Docker image, publishes it to Docker Hub and restarts the container on EC2. The page shows which commit is live, so a change is easy to verify.

## How it works

```mermaid
flowchart LR
    A[Push to main] --> B[GitHub Actions]
    B --> C[Build Docker image]
    C --> D[Push to Docker Hub]
    D --> E[SSH to EC2: pull and restart]
    E --> F[Health check on /health]
```

1. A push to `main` starts the workflow in `.github/workflows/deploy.yml`.
2. The `build-and-push` job builds the image from the `Dockerfile` and pushes it to Docker Hub with two tags: `latest` and the short commit id.
3. The `deploy` job connects to the EC2 server over SSH, pulls `latest`, and replaces the running container.
4. The job then calls `/health` and fails the run if the site does not answer.

## Tech stack

| Area | Tool |
|---|---|
| Cloud | AWS EC2 (Ubuntu), Security Groups |
| Containers | Docker, Docker Hub |
| Web server | Nginx (alpine image) |
| CI/CD | GitHub Actions |
| Scripting | Bash |

## Project structure

```
.
├── app/index.html               The website
├── nginx.conf                   Nginx config, including the /health endpoint
├── Dockerfile                   Builds the image and stamps the commit id into the page
├── scripts/setup-ec2.sh         One-time Docker install on the server
└── .github/workflows/deploy.yml The CI/CD pipeline
```

## Run it locally

```bash
docker build -t aws-ec2-docker-cicd .
docker run --rm -p 8080:80 aws-ec2-docker-cicd
```

Open http://localhost:8080. Locally the page shows `local` as the commit id, because the pipeline fills in the real one.

## Set it up yourself

**1. EC2 server.** Launch an Ubuntu instance and open ports 22 (SSH) and 80 (HTTP) in its security group. Connect and run:

```bash
bash scripts/setup-ec2.sh
```

Log out and back in so Docker works without `sudo`.

**2. Docker Hub.** Create a public repository named `aws-ec2-docker-cicd` and an access token with read and write permission.

**3. GitHub secrets.** In the repository, go to Settings, Secrets and variables, Actions, and add:

| Secret | Value |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | The Docker Hub access token |
| `EC2_HOST` | Public IP address of the EC2 instance |
| `EC2_USER` | `ubuntu` |
| `EC2_SSH_KEY` | Full contents of the `.pem` key file |

**4. Push to `main`.** The pipeline runs, and the site is live at `http://<EC2_HOST>`.

## Security notes

- The `.pem` key and all credentials are stored only as GitHub secrets. They are never committed (see `.gitignore`).
- SSH uses key-based login only.
- Port 22 is open to the internet because GitHub-hosted runners do not have a fixed IP address. A stricter setup would use a self-hosted runner, AWS Systems Manager, or temporarily allow the runner's IP during deployment.
- The site is served over HTTP. Adding HTTPS (a domain plus a certificate) would be the next step.

## Possible improvements

- Create the EC2 instance and security group with Terraform.
- Add HTTPS with a domain name and a certificate.
- Add a test or lint step before the image is built.
- Replace SSH deployment with AWS Systems Manager.

## License

MIT
