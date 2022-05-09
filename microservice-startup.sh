#!/bin/bash

export TF_STATE_BUCKET_MICROSERVICE="anogatorprotagona-tfstate"
export AWS_DEFAULT_REGION="us-west-2"

if [[ ! -e /usr/bin/curl ]]; then # curl application check
  
  sudo apt-get install -y curl
else
  echo "curl already installed!"
fi

if [[ ! -e /usr/bin/zip ]]; then # zip application check
  
  sudo apt-get install -y zip
else
  echo "zip already installed!"
fi


if [[ ! -e /usr/bin/unzip ]]; then # unzip application check
  
  sudo apt-get install -y unzip
else
  echo "unzip already installed!"
fi



TERRAFORM_UBUNTU_INSTALLATION () { 
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
}

TERRAFORM_CENTOS_INSTALLATION () {
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform
}

TERRAFORM_FEDORA_INSTALLATION () {
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf -y install terraform
}

TERRAFORM_MAC_INSTALLATION () {
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    
}


if [[ ! -e /usr/bin/terraform ]]; then
    TERRAFORM_UBUNTU_INSTALLATION || TERRAFORM_CENTOS_INSTALLATION || TERRAFORM_FEDORA_INSTALLATION || TERRAFORM_MAC_INSTALLATION
else
    echo "Terraform already installed!"
fi



if [[ ! -e /usr/local/bin/aws ]]; then  #checking to see if aws-cli is installed.  
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
else
  echo "aws cli already installed!"
fi


#defining our tf state bucket

aws s3api create-bucket --bucket $TF_STATE_BUCKET_MICROSERVICE --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true


#Running TF Config

terraform init && terraform validate && terraform apply -auto-approve