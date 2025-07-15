# Dockerfile-strapi-from-repo

## Feature

- Support cloning your strapi project from git repository.
- Automatically copy .env from the root directory of the mount directory to the strapi directory.
- Run the Strapi project

## Environment Variables

`GITHUB_REPO_URL`: Github repository name, only used to clone the repository from the docker container

`GITHUB_USER`: Github username, only used to clone the repository from the docker container

`GITHUB_TOKEN`: Github token, only used to clone the repository from the docker container

`GITHUB_BRANCH`: Github repository branch, default is master, only used to clone the repository from the docker container

`GIT_AUTHOR_NAME` : The default is DockerContainer, which is used when git push

`GIT_AUTHOR_EMAIL` : The default is DockerContainer, which is used when git push

You can put .env in the root directory of the mount directory, and the container will automatically move to the project directory(/host/data directory).

## Directory

Please mount the host directory to the container's `/host` directory.

The container will automatically clone the strapi project to the `/host/data` folder.

## Prerequisites

1. Modify your repository's strapi/.gitignore and comment out the

   - .`tmp`
   - `public/uploads/*`
   - `.env`

   And git push to the git repository.
2. Append the following content to your `.env` file

```
#Github
GITHUB_REPO=YOUR_GITHUB_REPO
GITHUB_BRANCH=YOUR_GITHUB_BRANCH
GITHUB_USERNAME=YOUR_GITHUB_USERNAME
GITHUB_TOKEN=YOUR_GITHUB_TOKEN
```

## Quick Start

```
docker run -d \
  --name strapi-from-repo \
  -e GITHUB_REPO_URL="https://github.com/your-username/your-repo.git" \
  -e GITHUB_USER="your-username" \
  -e GITHUB_TOKEN="your-token" \
  -e GITHUB_BRANCH="your-branch" \
  -p 1337:1337 \
  -v /your/local/host/path:/host \
  herfom/strapi-from-repo

```

Docker Compose

```
version: '3'

services:
  strapi:
    image: herfom/strapi-from-repo
    container_name: strapi-from-repo
    environment:
      - GITHUB_REPO_URL=https://github.com/your-username/your-repo.git
      - GITHUB_USER=your-username
      - GITHUB_TOKEN=your-token
      - GITHUB_BRANCH=your-branch
    ports:
      - "1337:1337"
    volumes:
      - /your/local/host/path:/host
    restart: unless-stopped
```
