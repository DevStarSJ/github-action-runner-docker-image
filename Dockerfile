FROM --platform=linux/amd64 ubuntu:latest

ARG AWS_ACCESS_KEY_ID=""
ARG AWS_SECRET_ACCESS_KEY=""

# https://github.com/actions/runner/releases
ARG RUNNER_VERSION="2.308.0"

# 아래 값들은 docker runt 실행시 주입해줘야 함
ARG AUTH_PAT="your-github-personal-access-token"
ARG GITHUB_ORGANIZATION="your-github-organization-name"

# Github Action runner는 admin 권한으로는 실행이 안됨
RUN useradd -m docker
RUN apt-get -y update && apt-get -y install curl git openssl build-essential zip unzip sudo
RUN apt-get install -y --no-install-recommends libssl-dev libcurl4-openssl-dev

# kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 
RUN chmod a+x kubectl
RUN mv kubectl /usr/local/bin/kubectl

# helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN rm get_helm.sh

RUN mkdir -p ~/.helm/plugins
RUN helm plugin install https://github.com/hypnoglow/helm-s3.git

# aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install 
RUN rm awscliv2.zip

# aws credentials to update EKS kubeconfig
RUN mkdir /root/.aws
RUN echo "[default]\naws_access_key_id = $AWS_ACCESS_KEY_ID\naws_secret_access_key = $AWS_SECRET_ACCESS_KEY" > /root/.aws/credentials

# eksctl login
RUN aws eks --region ap-northeast-2 update-kubeconfig --name deepsearch-blue

# Github Actions Runner
RUN mkdir actions-runner && cd actions-runner && \
    curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz && \
    tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz && \
    chown -R docker:docker /actions-runner
RUN sudo /actions-runner/bin/installdependencies.sh

# runner can't run as root
USER docker

# GithubAction self-hosted runner 에서 등록시 사용가능한 token을 주지만, 1시간 정보밖에 유효하지 않아서, 어쩔수 없이 PAT를 사용함. 추후 더 안전한 방법으로 변경해야함.
ENTRYPOINT /actions-runner/config.sh --url $GITHUB_ORGANIZATION --pat $AUTH_PAT --name eks_runner --unattended --replace && \
            bash /actions-runner/run.sh
