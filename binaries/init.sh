#!/bin/bash 

################################################################################
#Script Name	:init.sh                                                       #                                       
#Description	:Allows to build and configure the jenkins instance on AWS     #
#Author       	:Ghassen CHARNI                                                # 
#Email         	:ghassen.cherni@gmail.com                                      #
#Client         :Artifakt (DevOps Assesment Test)                              #
################################################################################


###### Deploying the Jenkins EC2 instance

terraform init

terraform plan -out=tfplan -input=false

terraform apply -lock=false -input=false tfplan



###### Configuring Jenkins with Ansible

# Sleep until full starting the instance
sleep 30
echo "waiting for SSHD daemon"

# To avoid host key checking during running install
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook artifakt_jenkins.yml -i hosts.ini -v -u ec2-user

###### Adding AWS / Gitlab credentials and creating JOBS using jenkins-cli binary
source /tmp/jenkins.env

echo "#####################################################################################################################"
echo "#                                                                                                         "
echo "# Please follow these steps in order to finish the Jenkins deployment:                                    "
echo "#                                                                                                         "
echo "# 1- Open the web browser and connect to : ${JENKINS_URL}                 "   
echo "#                                                                                                         "
echo "# 2- Put the Initial Admin Password : ${INIT_PASSWORD} then click on "continue"                             "
echo "#												                  "
echo "# 3- Select “Install suggested plugins” and wait until plugins installation finished                        "
echo "#                                                                                                           "
echo "# 4- Continue with the “admin” without adding “First Admin User”                                            "
echo "#														  "
echo "# 5- Keep the Jenkins URL as the default one ( ${JENKINS_URL} ) then click on save and finish.              "
echo "#                                                                                                            "
echo "# 6- Click on “Start using Jenkins”                                                                          "
echo "#													           "
echo "# 7- Once Jenkins is ready, press “Yes” to continue                                                          "
echo "#######################################################################################################################"

while true;
do
    read -r -p "If you have activated the admin / the default plugins, tape 'Yes' to continue configuring Jenkins " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
	    source /tmp/jenkins.env

	    echo "let's restart Jenkins"
	    java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" restart
	    sleep 40
	    echo "Jenkins Restarted"
            echo " "
	    
	    echo "Let's create the aws credentials"
	    java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" create-credentials-by-xml system::system::jenkins _  < jenkins_files/aws_credentials.xml
	    echo " "

	    echo "Let's create the gitlab credentials"
	    java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" create-credentials-by-xml system::system::jenkins _  < jenkins_files/gitlab_registry.xml
	    echo " "

	    echo "Create 'terraform_aws_eks_psg' job..."
	    java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" -webSocket create-job terraform_aws_eks_psg < jenkins_files/terraform_aws_eks_psg.xml

	    echo "Create 'notes_k8s' job..."
            java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" -webSocket create-job notes_k8s < jenkins_files/notes_k8s.xml

	    echo "Create notes_docker job..."
	    java -jar binaries/jenkins-cli.jar -auth admin:"${INIT_PASSWORD}" -s "${JENKINS_URL}" -webSocket create-job notes_docker < jenkins_files/notes_docker.xml


            # Delete the Jenkins Env File and AWS/Gitlab Credentials
            rm /tmp/jenkins.env
	    rm jenkins_files/aws_credentials.xml jenkins_files/gitlab_registry.xml

        exit 0
   fi 
done

