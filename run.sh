#!/usr/bin/env bash

##################
# GET CAPSULE NAME AND GENERATE CAPSULE VERSION
##################
# Read the YAML file
yaml=$(cat config.yaml)

CAPSULE_NAME=$(echo "$yaml" | sed -n 's/^ *capsule: *//p')
CAPSULE_VERSION=$(uuidgen | cut -c-8)

##################
# SAVE CAPSULE VERSION TO GITHUB REPO
##################
echo "SAVING CAPSULE INTO GITHUB"
git add .
git commit -m CAPSULE_VERSION
git push

##################
# BUILD AND PUSH CONTAINER TO ECR
##################
# Get the account number associated with the current IAM credentials
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [[ $? -ne 0 ]]
then
    exit 25
fi

# Get the region defined in the current configuration (default to us-west-2 if none defined)
AWS_REGION=$(aws configure get region)
CONTAINER_FULLNAME="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${CAPSULE_NAME}:${CAPSULE_VERSION}"

# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${CAPSULE_NAME}" > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
    aws ecr create-repository --repository-name "${CAPSULE_NAME}" > /dev/null
fi

# Get the login command from ECR and execute it directly
# $(aws ecr get-login --region ${AWS_REGION} --no-include-email)

# Build the docker image locally with the image name and then push it to ECR
echo "BUILDING CONTAINER IMAGE"
# docker build --no-cache -t ${CAPSULE_NAME} -f environment/Dockerfile .
# docker tag ${CAPSULE_NAME} ${CONTAINER_FULLNAME}

sm-docker build . --file environment/Dockerfile --repository ${CAPSULE_NAME}:${CAPSULE_VERSION}

echo "PUSHING IMAGE TO ECR"
# docker push ${CONTAINER_FULLNAME}

##################
# LAUNCH JOB IN SAGEMAKER
##################
# echo "LAUNCHING JOB RUN IN SAGEMAKER"
# python reproducible_run/job.py --job_name ${CAPSULE_NAME}-${CAPSULE_VERSION} --container_image ${CONTAINER_FULLNAME}
