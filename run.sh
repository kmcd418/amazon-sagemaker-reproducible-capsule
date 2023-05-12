#!/usr/bin/env bash

##################
# Save Capsule version to GitHub repo (commit code)
##################


##################
# build Docker image and push it to ECR to be ready for use by SageMaker.
##################
image=$1

if [[ "$image" == "" ]]
then
    echo "Usage: sh $0 <image-name>"
    exit 1
fi

# Get the account number associated with the current IAM credentials
account=$(aws sts get-caller-identity --query Account --output text)
if [[ $? -ne 0 ]]
then
    exit 25
fi

# Get the region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws configure get region)
fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image}:latest"

# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
    aws ecr create-repository --repository-name "${image}" > /dev/null
fi

# Get the login command from ECR and execute it directly
$(aws ecr get-login --region ${region} --no-include-email)

# Build the docker image locally with the image name and then push it to ECR
# with the full name.

echo "Building image with name ${image}"
docker build --no-cache -t ${image} -f Dockerfile .
docker tag ${image} ${fullname}

echo "Pushing image to ECR ${fullname}"
docker push ${fullname}