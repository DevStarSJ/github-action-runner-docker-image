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
