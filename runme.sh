#!/bin/bash
############################################
#Global variables
############################################

TERRAFORM_CHECK=$(find /usr/bin -type f -name "terraform")
TERRAFORM_VERSION="0.11.5"
GMAIL_ACCOUNT_USERNAME_FOR_SSH="techspec214"

#see https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys for more detials on how to set up the ssh keys
#it mentions that the comment is the username
#in this case we have used project-wide-ssh keys for easier management
#otherwise if we used instance-level public ssh keys 
#when the loadbalancer hits 40% and creates a new instance 
#we would not be able to get access to it becuase the key has already been used
#by another instance
#this would mean that the key which was created would only be usefull for 1 instane and not the other

ssh_key_creation_for_instances () {
    mkdir vm_instance_keypair
    ssh-keygen -t rsa -b 4906 -f vm_instance_keypair/gcloud_instance_key -C $GMAIL_ACCOUNT_FOR_SSH -N ''
    echo "Restricting acess to private key IE setting readonly acess"
    sleep 2
    chmod 400 vm_instance_keypair/gcloud_instance_key
    echo "Starting SSH agent to manage SSH keys"
    sleep 2
    eval ssh-agent $SHELL
    sleep 2
    echo "Adding private ssh key into the user agent so that it can be used for all ssh commands for authentication"
    #ssh-add command mentioned in https://cloud.google.com/compute/docs/instances/connecting-advanced#sshbetweeninstances
    ssh-add vm_instance_keypair/gcloud_instance_key
    #N '' means no passphrase but can be added for additional security
    #more security stuff whcih can be talked about https://cloud.google.com/solutions/connecting-securely#port-forwarding-over-ssh
}

terraform_install_check () {
    if [ "$TERRAFORM_CHECK" ]; then

cat << EOF
############################################
verifying Terraform installation
############################################
EOF
    terraform

else

cat << EOF
############################################
Terraform binary not found assuming that 
terraform has not been installed
############################################
EOF

sleep 2

cat << EOF
############################################
Installing Terraform
############################################
EOF

wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip
sudo unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip -d /usr/bin
    fi
}

terraform_load_balancer_init () {
    terraform init
    terraform validate
    terraform apply -auto-approve | tee build.log
}

certifcate_creation () {
    cat << EOF
################################################
Creating SSL Certifaces for use with terraform
and the load balancer
################################################
EOF
sleep 2

mkdir ssl_cert
 cd ssl_cert
 GLOBAL_LOAD_BALANCER_IP=$(grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"  ../static_IP/terraform.tfstate)
 echo 
 sudo openssl genrsa -out private.key 2048 #private key does not ask us about subject params
 openssl req -new -key private.key -out example.csr -subj '/C=UK/ST=London/L=London/CN='$GLOBAL_LOAD_BALANCER_IP''
 sudo openssl x509 -req -days 365 -in example.csr -signkey private.key -out certificate.crt #certificate file
#may need code below for later use
#sudo openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes -subj '/C=UK/ST=London/L=London/CN=www.madboa.com'
    #where subj means subject
    #in means input file
    #nodes means dont decrypt using output key 
    #out means output file
    #-x509 output a x509 structure instead of a cert. req.
    #-new mewans new request
    #source https://www.endpoint.com/blog/2014/10/30/openssl-csr-with-alternative-names-one
    cd ..
}

terraform_static_global_IP_init () {
    cd static_IP/
    terraform validate
    terraform init 
    terraform apply -auto-approve | tee static_IP_build.log
    COMPUTED_IP_ADDRESS_FROM_TERRAFORM_TFSTATE=$(terraform show | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    echo "substiuting IP address in load_balancer.tf"
    sed -i.bak 's/ipaddr1/'$COMPUTED_IP_ADDRESS_FROM_TERRAFORM_TFSTATE'/' ../load_balancer.tf
    cd ..
}

    overall_script () {
    terraform_install_check
    terraform_static_global_IP_init
    certifcate_creation
    terraform_load_balancer_init
}

accounts_json_check () {
    if [[ -f account.json && -f static_IP/account.json ]]; then
    echo "Account.json exists both in the current directory and in the static_ip directory "
    echo "continuing to run the rest of the script"
    sleep 2
    overall_script

    elif [[ ! -f account.json && -f static_IP/account.json ]]; then
    echo "The file account.json does not exist in the current directory but has been found in the static_IP directory"
    echo "please add file account.json to the current directory then rerun the script.. now exiting"
    sleep 5
    exit 130
    elif [[ -f account.json && ! -f static_IP/account.json ]]; then
    echo "The file account.json exist in the current directory but has not been found in the static_IP directory"
    echo "please add file account.json to the static_IP directory then rerun the script.. now exiting"
    sleep 5
    else
    echo "echo The file account.json does not exist in the current directory or the static_IP directory"
    sleep 5
    echo "Please create a service account for API acess in google cloud in which an account.json file will then be created"
    echo "then add the scripts to the current directory and the static_IP directory and then rerun the script"
    sleep 5
    exit 130
    fi
}


#http://www.tldp.org/LDP/abs/html/exitcodes.html exits via ctrl +c as suggested by this article

cat << EOF 
#########################################
This script is desighned to perform 
the Devops test for Ravelin
by 
provisioning 

1. A load balancer
2. Auto scaling with network loadbalancing
3. Instance template (so that VM can be created by it and added to the instance gorup 
to form a backend for the loadbalancer)
4. Backend 
5. Instance groups

It should be noted that this script attempts 
to create a slef sighned certificate
for use with the load balancer 
through attmepting to interpret the
global compute address
once interpreted it will be added to
the comman name field
however the problem with this is that
as it is self created certificate
even if the csr (cert sighning record)
does become signed through a authority 
such as https://gethttpsforfree.com/
or even http://getacert.com/
errors will ensue due 

1. vai getacert .. (net::ERR_CERT_AUTHORITY_INVALID).
meaning that the certifcate authority is invalid i.e untrusted
and this breaks the web of trust needed to 
have a "green" trusted certifcate
on top of thie cert produced has a limited time span of around 7 days for some reason
(will double check this)

2. vai https://gethttpsforfree.com/ 
this is a manual way of sighning certs througbh 
letsencrpyt which is a popular CA
the problem with this is that an erorr is presented
Error: Account registration failed. 
Please start back at Step 1. { "type": "urn:acme:error:malformed", "detail": "JWS verification error", "status": 400 }
The error above is possibly due to not having a reverse proxy on the servers
however the problem in setting up the reverse proxy would be that we would have to essentially redirect traffic from port 80 ro another port like 443
on top of this many examples exspress that a domain name should be used instead to validate the certifcates
and in this case that is approiate as tyhe user is unlikely to remember to 9 digits for a domain name
on top of this the google docs explain that for a https load balancer https requests can be terminated at the load balancer 
so perhaps a wildcard  created cert would elevate this problem as lets encrypt would then be able to pose a challange
to the doamin 
it appears the error fails the JWS (Jason Web signature) as it is not able to challange the domain in question
source https://github.com/diafygi/gethttpsforfree
other sources https://rubyinrails.com/2017/09/18/google-cloud-https-load-balancing-with-letsencrypt-certificate/
Certbot will try to verify the domain by giving you a unique URL and it will expect a unique response to make sure the domain is owned by you.
goddady proof https://uk.godaddy.com/help/can-i-request-a-certificate-for-an-intranet-name-or-ip-address-6935
domain names could be implemented with cloud DNS to point to the correct Ip address through an A record for instance
https://cloud.google.com/dns/
#########################################
EOF

sleep 5

cat << EOF
#############################
Initalising script
########################
EOF

accounts_json_check
