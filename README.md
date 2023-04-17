- # drone
- ## Abstract
	- [Drone](https://drone.io) is a modern continuous integration platform that empowers automated build, test and release workflows using a powerful, cloud native pipeline engine.
	  
	  **Drone** has joined [Harness](https://harness.io). The product page has moved to [Continuous Integration](https://harness.io/products/continuous-integration) and the project moved repomoved to [harness/drone](https://github.com/harness/drone/).
	  
	  This container generally connects to [GitHub](https://github.com) to pull other container's code-base down and builds the container image via [Podman](https://podman.io) and then pushes the image to [Docker Hub](https//hub.docker.com) to be used in a Kubernetes cluster.
- ## Features
	- **Note:** All of the features are distributed seperately and therfore needs to have their versions updated in the `docker-compose.yml` or `drone.yml` files.
	- **podman:** OCI/Open Source replacement for docker
	- **CLI:** command line interface
	- **Runners**:
		- **Docker:** runner in a container (dind)
		- **Exec:** runner within the server container
		- **Kube:** runner within a pod in the k8s cluster
## Details
	- ### podman
		- [podman](https://podman.io) is a daemonless container engine for developing, managing, and running OCI Containers on your Linux System. Containers can either be run as root or in rootless mode.
- ### CLI
	- [Command line client](https://github.com/harness/drone-cli) for the Drone continuous integration server.
### Runners
	- #### Docker
	- The [docker runner](https://github.com/drone-runners/drone-runner-docker) executes pipelines inside Docker containers. This runner is intended for linux workloads that are suitable for execution inside containers. This requires Drone server 1.6.0 or higher. Need to figureout the relationship to  [harness/harness-docker-runner](https://github.com/harness/harness-docker-runner).
#### Exec

The [exec runner](https://github.com/drone-runners/drone-runner-exec) executes pipelines directly on the host machine. This runner is intended for workloads that are not suitable for running inside containers. This requires Drone server 1.2.3 or higher.
#### Kube

The [kubernetes runner](https://github.com/drone-runners/drone-runner-kube) executes pipelines inside Kubernetes pods. This runner is an alternative to the docker runner and is optimize for teams running Drone on Kubernetes. This requires Drone server 1.6.0 or higher.
## Deploy

Being a bootstrap container you may need to push the image to the repository.

Parameters:
- {DRONE_SERVER_VERSION}: Version from the build script
- {DOCKER_USERNAME}: Docker Hub User Name
- {DOCKER_PASSWORD}: Docker Hub Password
  
  On the desktop credentials are usually handled by the desktop app, check `~/.docker/config.json` to confirm.  This should eliminate the need for `docker login --username={DOCKER_USERNAME} --password={DOCKER_PASSWORD} docker.io`
  
  **Integration Script**
  ```
  docker tag drone:dev docker.io/gautada/drone:{DRONE_SERVER_VERSION}
  docker push docker.io/gautada/drone:{DRONE_SERVER_VERSION}
  ```
## Architecture
## Context

![Context Diagram](https://plantuml.com/plantuml/svg/dLHDZzem4BtpAxnHfGOfX0k7gggAkWHjKQ6Bbgvwg2faaY5OE7PaEwkDAF-zazZvOBUqKhamUZFlpSmRmmqJCIyI81zca_5i4kP5nZyERYxHxKmA0y_cBrdA1AYh-IoN0iGrVbGAch7uMXPoBikiem_U4ZSFHYFxmUYqARM1xDSSKofNJCFsV2iBaL1L-fGpgWF2wGvuG4vJK-Pm3iZKq1JXDvo9un0rrg2q5AVj_DcSNt2c2UXOuRT6RGElkRRz_t3TGhM5tKhrKYt-Kj50V13_dggMSEw_adQuamx3q18UW5F3fD07blSvbePPtyY0x9NC0bAtjxGVimbPSohCushvqpyOa-ltut5U8NYsaJO9PximPUPGx48cyRIZfdoC7XXcE13FNPP4ZAQAPcH48eLJUeE1zRUorxSY0V7kwi33Q2CB5GCkXGzdHGLDGI4NysG3wed5u0tx2ecCZu2-UL4TL0gjrRXYBZKpKfKeyISOjPoOdyiaetW8Rrq7bqAs1aNkPukUqAVreft6Jwhrga7gDHsTYK8McjmMZ2TkXWl8SZiHD0IezGFeTJkMCgPyl5RiYHeW_HegaghBdgM5gezF5c8lLLR7NH_ybIfvV8SFp5kviEhsfTY14c10zxR4uvfAekbBZbrLxdALaKjQRgFsfFKcYE8pspwqQ6FIDyLIN4KZhose5h-QTudUtFRlfAc8cehsZeyQEdg3jiy5OQ2sOh3vVFzzkvpVpRz6_l0t)
## Container

![Container Diagram](https://plantuml.com/plantuml/png/dLDRRzem57xFhpYD9WqaBYyyJTDG6z2An5e4g_emJSWa9ZcgOrksqnOn_lkE7I1GraqQBpcSx-9piQzGfgBAE7nE1lraqDDLARv4L-VPPQAauw_kBoX3oSsxUAcLvF8z_MWZMOdfUoZNGctAHXvzX7qz57Nh7qNRnSOwNluQ4sIqGSkNknjLoOoPJOi9PBO3WgsuwC1sw3QQxpemT2odz0U1ygbD7ZDkh9BRvVZLxTveXXctgQ6l9M_7BxNryV-ZtJSKHjYq59ewvjywEfuMyjzL1Olzz2-iz_czTQ_NgmLpBfX39Ms1-bHJomXjETM1jL5b1yBnjUn7Ce2POD8zV9l-R1NEQVkftzS-GslhMfS9NFLoT4Mrwg6YrNOFz3xDmA4J7E9Zmp12bXjMGXT6XkgCe-Y8BOzxpJpKWJXGmhHGLggoS5EXoE8sRAEJHcrQyAmId0OM9_Fxkr5CmUAGz7--5nnIyih0XdN2KHAtpvouUGusYn1uwRNM0jCmEMYotl1X0emS7OLCQwYri5O6aaaoEZSsbPJ1U1u2R_6ep1FnxrJ63uur2z02WvSQbWI3MeTJlEs-WNFtLA1lVJe91MSbIhJEX9fzPgfUGF1dBY13arArPmneaR0DwD_NcgNyt5ghh6Hq8-DP2BnTiylwRVZSVJ9fBZLSpoRU9VAtQZa_tSznm8SgwMKEFRTcXaR-n6ae1xIU3x76hpojd6VicglK4YhFKUQX-n25vM4QParlul1fdsWAHibRp0kuVcP8Jn85kis585hStZykf-EluxjHg_qR)
## Component

![Component Diagram](https://plantuml.com/plantuml/png/dPDhQzim58Q_-rUeOT04Sc7GJsEiUBPxWVX2d7IKCOBYgB6eR1b9PZLf_lkEvOlSb6wmV73CESzxTFIUumkQ9wpS4_JLkLeuL_EYpDWtw-9jTElmN94NzPSifZaH7-QpWkSa_qZlLZdEQF9HbXICLvcHMvUexGVUPiqFtevn9HN9NZr8YK9GIRQdxxpCzrXKOymebbF4y8wmAJfUgweWfocwLlW0uK-CviyJg14H8Nb-t7elwdIckTuJcGZubr1RaVVQvlZ_qRONqXQQA-bBzV7pYeeaQVxlhdI9rlrtfTjuMte-dpU25M5OKPxBb1P3JIE3x5ZnANeIF9iYVNmZ--bSeOZXN6tyvQzngbGXlomMHHs1iSsasZEwcn-eIilTd78OxQp35-21eeeHDEgxGYx51u4pD4EkWCZ8ilffEijDlFPMKy1P2QwBqGGTBTJd0zltuiXsF202d15Pu8GqZ85SBrg6ZxuNh84oIzPYXej25u28xxkCIJbXiBRlWwQJRb8zDd3O3pVDCLXXv8CSZj7CoUeU1du8bnlV-zpX3voL6T5y3HhEMTht_Xc678PfLiF06ZHwwB1wmobO1WQRmWQCr-7AllMWT1o395PSu0E1eb82UBAi7dLtzQPtWjgXj98qmGoref5UxC5Cwe81KR-vU4QsKZX9oTx0ODgGlXdIDnHM8qwnw3ZJSTF4dRtIXe6iuuORtlRgtgyy1_fzx52N2f900vN6JzObNB3URpqkWCmazCmaKXmbUiv4eAUwAQa_Uf3NiXxl9xEHH8jmaX3jO8rrMJqKFI-vq1VlW3fnDeYwK9jzcp7-s_eCZRMVwHdPcJG0MwxDlF4dAdUCohIf5z-5FxPBxzOBtF7a3m00)
## Administration
### Checklist
- [2022-11-28 Checklist](https://github.com/gautada/drone-container/issues/34)
### Issues

The official to list is kept in a [GitHub Issue List](https://github.com/gautada/drone-container/issues)
## Notes
- The podman environment needs to use the `--format` to build like docker.  This needed if the `VOLUME` command is used in the container file. To remove the subsequent warning user `--format docker`.
- Access tokens are used for docker.io image repository and stored in the `orgsecrets` function. Tokens are stored in password management. Token management is in `https://hub.docker.com/settings/security`.
- Just to record somewhere the mechanism to build a multi-architecture container image distribution.
  
  **Build and push architecture 1**
  ```
  podman build --file Containerfile --no-cache --tag img:dev .
  podman tag img:dev docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH1}
  podman login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD docker.io
  podman push docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH1}
  ```
  
  **Build and push architecture 2**
  ```
  podman --remote --connection x86 build --file Containerfile --no-cache --tag img:dev .
  podman --remote --connection x86 tag drone:dev docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH2}
  podman --remote --connection x86 login --username=$DOCKER_USERNAME --password=$DOCKER_PASSWORD docker.io
  podman --remote --connection x86 push docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH2}
  ```
  
  **Build and push manifest**
  ```
  podman manifest create img:man
  podman manifest add img:man docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH1}
  podman manifest add img:man docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH2}
  podman tag img:man docker.io/$DOCKER_USERNAME/img:{VERSION}
  podman push docker.io/$DOCKER_USERNAME/img:{VERSION}
  ```
  
  **Clean-up**
  ```
  podman docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH1}
  podman rmi drone:dev
  
  podman --remote --connection x86 rmi docker.io/$DOCKER_USERNAME/img:{VERSION}-{ARCH2}
  podman --remote --connection x86 rmi drone:dev
  
  podman rmi drone:man
  ```




