# github-action-runner-docker-image
Docker Image for GithubAction self-hosted-runner

## build docker images

```bash
docker build -t github-runner . --platform linux/amd64 --build-arg AWS_ACCESS_KEY_ID=YOUR_KEY --build-arg AWS_SECRET_ACCESS_KEY=YOUR_SECRET
```

- push ECR
```bash
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com

docker tag github-runner:latest $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/github-runner:latest
docker push $ACCOUNT.dkr.ecr.ap-northeast-2.amazonaws.com/github-runner:latest
```

## workflow example

- GithubAction Workflow의 가장 간단한 작업의 예제입니다.
- 해당 예제를 보면 workflow 상에서 AWS credential 주입 및 EKS login 작업을 하고 있습니다. 이미 Dockerfile에서 그 작업을 직접 하는 것으로 작성하였습니다. 이 둘은 중복된 작업이므로 각자 상황에 맞게끔 하나를 제거하면 됩니다.

