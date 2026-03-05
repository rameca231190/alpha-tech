# This page is used to set up eks cluster on top of AWS.


Dockerfile ---->  is used as a runtime for our terraform job, jenkins server will pull that image and execute code inside it. That way it will help us to isolate the processes.  It has list of the nececary packages inside as well as TF repo cloned to the image.

Note: If you are changing terraform code you have to rebuil that image with Jenkinsfile.

```
FROM alpine:3.19
ENV TERRAFORM_VERSION=1.14.6
ENV KUBECTL_VERSION=v1.35.1
ENV HELM_VERSION=v4.1.1

WORKDIR /app

RUN apk --no-cache update \
  && apk upgrade \
  && apk --no-cache add curl git wget unzip openssh jq bind-tools bash python3 py3-pip ca-certificates groff less \
  && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O terraform.zip \
  && unzip terraform.zip \
  && chmod +x terraform \
  && mv terraform /usr/local/bin/terraform \
  && rm terraform.zip \
  && wget "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -O helm.tar.gz \
  && tar -xzvf helm.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf linux-amd64 helm.tar.gz \
  && curl -L -o kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && pip3 install --upgrade pip \
  && pip3 install awscli

COPY alpha-tech-eks-terraform .
```
Jenkinsfile ----->     Used to build base image for creating EKS cluster. It builds a tagged image and also maintains a rolling `eks-tools-latest` tag that is used by the Terraform pipelines.


Jenkinsfile_tf_apply       ----> Used to create the actual cluster just import this file to jenkins pipeline. It uses the `versoview/base-image:eks-tools-latest` image built by the Docker `Jenkinsfile`.

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform init/plan/apply') {
            agent {
                docker {
                    image 'versoview/base-image:eks_dev_1'
                    registryUrl 'https://registry.hub.docker.com'
                    args '-u root:root'
                    registryCredentialsId 'dockerhub_generic'
                }
            }
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
                environment = 'dev'
            }
            steps {
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                timeout(time:1, unit:'HOURS') {
                    input("Proceed to apply DEV-EKS ?")
                }
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    pwd
                    terraform apply --var-file=values.tfvars --auto-approve=true
                    mkdir ~/.kube
                    terraform output kubeconfig > ~/.kube/config
                    aws eks --region ${aws_region} update-kubeconfig --name terraform-eks-${environment}
                    terraform output config-map-aws-auth > config-map-aws-auth.yaml
                    export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
                    kubectl apply -f config-map-aws-auth.yaml
                    kubectl get nodes
                    cat ~/.kube/config
                    '''
                }
                }
            }
        }
    }
}
```

Jenkinsfile_tf_destroy     ----> Used to destroy the cluster (be cearful with this pipeline). It also uses the `versoview/base-image:eks-tools-latest` image built by the Docker `Jenkinsfile`.

```
// a.groovy
import groovy.transform.Field
import groovy.lang.Binding
pipeline {
    agent any
    stages {
        stage('Terraform destroy') {
            agent {
                docker {
                    image 'versoview/base-image:eks_dev_1'
                    registryUrl 'https://registry.hub.docker.com'
                    args '-u root:root'
                    registryCredentialsId 'dockerhub_generic'
                }
            }
            environment {
                aws_access_key_id = credentials('aws_access_key_id')
                aws_secret_access_key = credentials('aws_secret_access_key')
                aws_region = 'ap-southeast-1'
                environment = 'dev'
            }
            steps {
                sh "aws configure set aws_access_key_id ${aws_access_key_id}"
                sh "aws configure set aws_secret_access_key ${aws_secret_access_key}"
                sh "aws configure set default.region ${aws_region}"
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    terraform init
                    terraform plan --var-file=values.tfvars 
                    '''
                timeout(time:1, unit:'HOURS') {
                    input("Proceed to destroy DEV-EKS ?")
                }
                script {
                    sh '''
                    cd alpha-tech-eks-terraform
                    pwd
                    terraform destroy --var-file=values.tfvars --auto-approve=true
                    '''
                }
                }
            }
        }
    }
}
```


values.tfvars              ----> is a variables storage so if you need to make your modifications and install cluster to different region update this file.

```
cluster-name = "terraform-eks-dev"
vpc_id = "vpc-0daa69bb1d5a65662"
env = "dev"
region = "ap-southeast-1"
public_subnets = ["subnet-01b0418aee7e852df", "subnet-0bf04db20c8f4dac4", "subnet-0544b876043ff43b4"]
image_id = "ami-02a3a200c350cb674"
```


eks-workers.tf           -----> has worker nodes configuration as well as autoscalling group, so if you need to make a change to desired or min/max amout of workers update those details. This configuration now uses a launch template and Auto Scaling Group that are compatible with modern EKS and Terraform 1.x.




Bellow is the notes with manual steps.

# AWS page with optimized AMI id's

https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html

# Setting up AWS EKS (Hosted Kubernetes)

See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide


## Download kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin


## Download the aws-iam-authenticator

wget https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.3.0/heptio-authenticator-aws_0.3.0_linux_amd64
chmod +x heptio-authenticator-aws_0.3.0_linux_amd64
sudo mv heptio-authenticator-aws_0.3.0_linux_amd64 /usr/local/bin/heptio-authenticator-aws


## Modify providers.tf

Choose your region. EKS is not available in every region, use the Region Table to check whether your region is supported: https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

Make changes in providers.tf accordingly (region, optionally profile)

## Terraform apply

terraform init
terraform apply


## Configure kubectl

terraform output kubeconfig # save output in ~/.kube/config
aws eks --region <region> update-kubeconfig --name terraform-eks-dev


## Configure config-map-auth-aws

terraform output config-map-aws-auth # save output in config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml


## See nodes coming up

kubectl get nodes


## Save and Export kubeconfig to your own path

export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config_alpha/config_dev 

## Create test app
kubectl create ns app-nginx
kubectl create -f manifests/test-app-nginx/deployment-svc-nginx.yaml

## Destroy
Make sure all the resources created by Kubernetes are removed (LoadBalancers, Security groups), and issue:

terraform destroy
