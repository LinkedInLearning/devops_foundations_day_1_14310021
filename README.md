# DevOps Foundations: Core Principles and Real‑World Practices for Modern Software Delivery

This is the repository for the LinkedIn Learning course `DevOps Foundations: Core Principles and Real‑World Practices
for Modern Software Delivery`. The full course is available from [LinkedIn Learning][lil-course-url].

![course-name-alt-text][lil-thumbnail-url] 

## Getting started

For all labs in this course, you can choose from one of the two following options:

1. **Codespaces**. Codespaces gives you a virtual environment with an IDE (Visual Studio Code), a terminal, and all the
   tools you need already installed, so you can write and run code from your web browser, without having to install
   anything locally. To use codespaces:

    1. Click the green Code button in the top right of the repo.
    2. Select "Create codespace on main."
    3. Give the Codespace a minute or two to boot up.

2. **Your own computer**. Alternatively, you can install and run everything from your own computer. Note that the
   scripts and commands in this course assume you’re on Linux or macOS; if you’re on Windows, you’ll need to use the
   [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) or
   [Cygwin](https://cygwin.com/).

    1. `git clone` this repo into a folder on your computer.
    2. Go into that folder.
    3. [Install Mise](https://mise.jdx.dev/getting-started.html).
    4. Use Mise to install the tools for this course:

    ```shell
    mise trust .mise.toml
    mise install
    ```

## Folder structure

The code to use at the start of a lab will be in a folder named `chapter-xx/lab-yy/begin`. The “official” solution for
what the code should look like at the end of a lab will be in a folder named `chapter-xx/lab-yy/end`.

For example, for the lab in chapter 1, section 2:

- `chapter-01/lab-02/begin`: Do all your coding in this folder.
- `chapter-01/lab-02/end`: The "official" solution in case you get stuck or want to compare your code.

<!-- TODO: fill in these URLs -->

## Running a Kubernetes cluster locally

- **If you're running these labs on your own computer**, [install Docker
  Desktop](https://www.docker.com/products/docker-desktop/), and use its built-in Kubernetes cluster.

- **If you're running these labs in Codespaces**, run `.devcontainer/start-k3d-cluster.sh` to create or start a local
  Kubernetes cluster powered by [K3D](https://k3d.io/stable/). This script will create a cluster named
  `devops-foundations` and automatically switch you to its Kubernetes context, whcih is called `k3d-devops-foundations`.

## AWS SSO in Codespaces

To authenticate to AWS on the CLI in Codespaces, use the device-code login flow. The very first time, run the
following:

```shell
aws configure sso --use-device-code
```

This will prompt you for:

1. A name for the SSO session
2. The SSO start URL (e.g., `https://x-xxxxxxxxx.awsapps.com/start`)
3. The AWS region (e.g., `us-east-2`)
4. The SSO registration scopes (e.g., `sso:account:access`)

It will then prompt you to open a new browser tab (allow this) to login to your AWS account. Once you've logged in, go
back to the terminal in Codespaces, and pick the AWS IAM Role you want to use, and give a name to that profile. You can
then use that profile to authenticate to AWS by setting the `AWS_PROFILE` environment variable. For example, try
running:

```shell
AWS_PROFILE=<PROFILE_NAME> aws sts get-caller-identity
```

After that, if your login expired, you can login again as follows:

```bash
aws sso login --sso-session <SESSION_NAME> --use-device-code
```

Set `<SESSION_NAME>` to whatever name you used when running `aws configure sso` the very first time.

## Codespaces Docker image

Codespaces in this repo runs on top of a Docker image built from the [`Dockerfile` in the `.devcontainer`
folder](/.devcontainer/Dockerfile). The Docker image lives in GitHub Packages. To push a new image:

1. (One time) Create a Classic GitHub Personal Access Token (PAT) with `packages:read` and `packages:write` scopes.
2. Login to GitHub Packages: `echo "<GITHUB_PAT>" | docker login ghcr.io -u brikis98 --password-stdin`.
3. Build and push the Docker image (run this command from the root of the repo so files such as `.mise.toml` are
   available in the build context):

    ```shell
    docker buildx build \
      -f .devcontainer/Dockerfile \
      --platform linux/amd64,linux/arm64 \
      -t ghcr.io/brikis98/devops-foundations-codespaces:<VERSION> \
      --push \
      .
    ```

[lil-course-url]: https://www.linkedin.com/learning/
[lil-thumbnail-url]: https://media.licdn.com/dms/image/v2/D4E0DAQG0eDHsyOSqTA/learning-public-crop_675_1200/B4EZVdqqdwHUAY-/0/1741033220778?e=2147483647&v=beta&t=FxUDo6FA8W8CiFROwqfZKL_mzQhYx9loYLfjN-LNjgA

