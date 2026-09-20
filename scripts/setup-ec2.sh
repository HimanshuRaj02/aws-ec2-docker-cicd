#!/usr/bin/env bash
# Run once on a fresh Ubuntu EC2 instance to install Docker.
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y docker.io curl git
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo "Docker is installed. Log out and log in again, then check with: docker --version"
