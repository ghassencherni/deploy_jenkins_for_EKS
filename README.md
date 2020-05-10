# deploy_jenkins
Allows to deploy / destroy Jenkins, used as orchestrator to manage pipelines : Artifakt Assessment Test

The script is composed by an ansible role "artifakt_jenkins", bash and terraform scripts.


## Requirements

- We need a Linux machine in order to run the first “init.sh” script to build our JENKINS instance.

- terraform (version 11) and aws-iam-authenticator binaries must be installed

- AWS account ( ex Free tier ) to create a user with access key (AWS access key ID and secret) with “AdministratorAccess” permission.

- AWS access key ID and secret key are configured on the Linux machine ( for example by adding “.aws/credentials” file or exporting AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY )

- A Gitlab account with public docker image registry ( Not needed, please use the default one, account name is hardcoded at this version ) 

- Ansible installed and configured ( tested with 2.9.1 version ) 

- Java must be installed 



## Getting Started

This script allows to deploy jenkins instance, it will be used later to build AWS infrastructure on AWS and deploy new Wordpress images on EKS.

The script uses :

- TERRAFROM to build the EC2 instance and configure security group on the default VPC

- ANSIBLE to configure JENKINS: deploying Docker, kubectl, copy-artifact plugin, ...

- JENKINS-CLI to add AWS/Gitlab credentials and Create the jobs 


## Variables

All variables are available on **terraform.tfvars** file, you can keep all default values except **aws_access_key_id** and **aws_secret_access_key** variables.

- AWS region where to run our Jenkins instance

   aws_region = "eu-west-3"


- The name of the public ssh key stored in AWS
    
   key_name = "artifakt_key"


- The public key for ssh connection 

   public_key_path = "~/.ssh/id_rsa.pub"


- The private SSH key, used by ansible to configure the Jenkins instance

   private_key_path= "~/.ssh/id_rsa"


- The size of the Jenkins instance, micro is sufficient for our deployment
   
   instance_type = "t2.micro"


- Please use the default one, account name is hardcoded at this version 

   gitlab_account = "myartifakt@outlook.fr"


- Please use the default one, account name is hardcoded at this version

   gitlab_password = "artifakt"


- The AWS ACCESS KEY ID

   aws_access_key_id = "PUT-YOR-ACCESS-ID"


- The AWS SECRET ACCESS KEY

   aws_secret_access_key = "PUT-YOUR-SECRET-ACCESS-KEY"


## Installation Steps 

1. git clone  https://github.com/ghassencherni/deploy_jenkins.git

2. cd deploy_jenkins

3. Give permission to the scripts 

chmod +x ./binaries/init.sh ./binaries/destroy.sh


4. Run the installation 

./binaries/init.sh 


5. During the installation the script will ask you to make some manual configurations: 

  - Open the web browser and connect to the provided URL                                                                                                        "
  - Put the Initial Admin Password then click on "continue"                            

  - Select “Install suggested plugins” and wait until plugins installation finished  

  - Continue with the “admin” without adding “First Admin User”       

  - Keep the Jenkins URL as the default one, then click on save and finish.    
                                                                                      
  - Click on “Start using Jenkins”                                   
                                                          
  - Once Jenkins is ready, press “Yes” to continue    



6. After finishing installing the script, connect to Jenkins using the "admin" user and the "initial admin password" in order to run the jobs : [terraform_aws_eks](https://github.com/ghassencherni/terraform_aws_eks), [wordpress_k8s](https://github.com/ghassencherni/wordpress_k8s) and [wp_custom_docker](https://github.com/ghassencherni/wp_custom_docker).

7. Run the first pipeline "terraform_aws_eks": it will build all AWS resources ( VPC, RDS, EKS, Public and Private Subnets,.. )

8. Run the pipeline wp_custom_docker, it will push the new Docker image (ghassen-devopstt) on Gitlab Registry and trigger wordpress_k8s pipeline that create the wordpress deployment on EKS and un the ALB ( currently only HTTP is vailable )


## Author Information

This script  was created by [Ghassen CHARNI](https://github.com/ghassencherni/)

