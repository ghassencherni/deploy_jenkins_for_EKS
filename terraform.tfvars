# AWS region where to run our Jenkins instance
aws_region = "eu-west-3"

# The name of the public ssh key stored in AWS
key_name = "artifakt_key"

# The public key for ssh connection 
public_key_path = "~/.ssh/id_rsa.pub"

# The private SSH key, used by ansible to configure the Jenkins instance
private_key_path= "~/.ssh/id_rsa"

# The size of the Jenkins instance, micro is sufficient for our deployment
instance_type = "t2.micro"

# Please use the default one, account name is hardcoded at this version 
gitlab_account = "myartifakt@outlook.fr"

# Please use the default one, account name is hardcoded at this version
gitlab_password = "artifakt"

aws_access_key_id = "PUT-YOR-ACCESS-ID"

aws_secret_access_key = "PUT-YOUR-SECRET-ACCESS-KEY"
