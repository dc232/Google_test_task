# Introduction
This project is designed to build a load balancer through terraform orchestration and also allows for the management of Google VM’s via external interface IP address through Ansible via gce.ini and gce.py files.

It should be known that I have had only 1 week to get myself familiar with GCP and its concepts and I am very much a novice when it comes to GCP.

However I have not let this deter me from attempting to complete the project.

The runme and Ansible scripts included in this project have been desighned with Ubuntu 16.04 in mind

## The Requirements of Project
 - [x] HTTP accepts a GET request to https://Loadbalancer-IP-address and return {foo:bar}
 - [x] Create a new Google Platform Project 
 - [x] Use f1-micro instances
 - [ ] Ensure the enviroment is completely secure
 - [x] Use Nginx/Apache or SimpleHTTPServer
 - [x] Return the correct headers
 - [x] If a server dies rebuild and re-add to the LB
 - [x] Minimum size of server auto-scaling group 1 and max 2
 - [x] IAM Acess

## Getting started 
### Prerequisites
1. Sign into google cloud and create a project
2. Type in the search bar API and services --> API library --> Google Compute Engine API
3. Enable the Google Compute Engine API for the project
4.  Create a service account through the following step
     1. Go to the API Dashboard by typing API into the search bar 
         - Then select Credentials APIs & Services
         - Click on Create credentials --> Service account key --> Create Service account 
         - Select Compute Engine default service account if avalible 
         - If Compute Engine default service account is not avalible then 
         - Click on New service account
         - Enter a name for the Service account and then click on next, 
         - Select the role as Compute Engine --> Compute Admin and then click on create
         - This will then create a .json file save this file as account.json
      
      1. For more information about service account click ont the link https://cloud.google.com/compute/docs/access/service-accounts
         1. The Link explains that a service account is a special account used by GCE instances to interact with other google Plaform API's. Service credentials can be used to allow applications to authorize themselves to a set of APIs and perform actions within the permissions granted to the service account and virtual machine instance.
         
     1. For more information about API Credentials, access, security, and identity click on this link ttps://support.google.com/cloud/answer/6158857?hl=en

## Installation and setting of variables
1. git clone https://github.com/dc232/Google_test_task.git
2. The project comes with 2 executable files, one called runme and the other Ansible
     1.  The runme file
          - Checks that Teraform is installed
          - Provisions the SSH Keys needed to acess the instances over the exsternal IP address
          - Creates a self sighned certifcate for use with the load balancer
          - Uses the Variable ```COMPUTED_IP_ADDRESS_FROM_TERRAFORM_TFSTATE``` to grab the IP address of the Global load balancer so that it can be used in the forwarding rules
     
     1. The runme file also executes the Ansible file to install 
        - python-pip
        - Python
        - Python3
        - Ansible
        - apache-libcloud (GCE dynamic inventory plugin)
 
3. Move the newly created account.json file to the project directory (Google_test_task) and also to the static_IP/ folder

## runme script important variables and functions
1. In runme modify the variable ```GMAIL_ACCOUNT_USERNAME_FOR_SSH``` as this needed to create a username for the SSH key setup under metada in GCP. The username is added as a comment to the puplic key in this case named gcloud_instance_key.pub located in the vm_instance_keypair folder upon creation as seen in the snippet below.
     
``` 
ssh_key_creation_for_instances () {
    mkdir vm_instance_keypair
    ssh-keygen -t rsa -b 4906 -f vm_instance_keypair/gcloud_instance_key -C $GMAIL_ACCOUNT_USERNAME_FOR_SSH -N ''
    #N '' means no passphrase but can be added for additional security
    echo "Restricting acess to private key IE setting readonly acess"
    sleep 2
    chmod 400 vm_instance_keypair/gcloud_instance_key
}

``` 


2. Also within runme to just build just the load balancer and not ansible or its subsequent components use ```vi runme``` and then disable the nested function Ansible_Integration as seen below

```  
       overall_script () {
    terraform_install_check
    ssh_key_creation_for_instances
    terraform_static_global_IP_init
    certifcate_creation
    terraform_load_balancer_init
#    Ansible_Integration
    Add_ssh_keys_ssh_agent
}
```

## Ansible script important variables
To setup variables in the Ansible script ```vi Ansible```
Then change ```GCEZONE``` varaible variable to reflect where you are erecting the infrastructure

## Ansible script important message 
1. Please ensure that you set the export path to the gce.ini file i.e set the location of where the file is before running the script or it will fail to initalise with gce.py

   1. To do this
        - Type ```pwd``` and make a note of the current working directory path
        - ```vi Ansible```
        - Search for the function ```GCE_ini_Config```
        - Modify sudo ```echo "export GCE_INI_PATH=~/Desktop/CICD/Ravelin_GCP_Project/gce.ini" >> ~/.bashrc``` to relfect where the file gce.ini is on the system
        - Adjust script timmers as needed
        
2. Please ensure that you cat the public key and add this to GCE 
   1. To do this
         - ```cat vm_instance_keypair/gcloud_instance_key.pub```
         - Copy the key information exactly
         - Click on Compute Engine
         - click on Metadata
         - Click on SSH Keys
         - Paste the key information 
         - Verify the puplic entered into GCE is the same as that presented in the console
         
Please Note: In the futre I plan to use a terraform template to add the public key to GCE automatically. This is still being reaserched to find out how to do this

## Terraform variable setup
Variables to setup terraform can found in the file variables.tf and are set with the following paramters
Please ```vi variables.tf``` as needed to update the variables to reflect the enviroment

```
variable "region" {
  default = "us-central1"
}

variable "region_zone" {
  default = "us-central1-f"
}

variable "project_name" {
  description = "Name of the project otherwise known as project ID"
  default = "smart-radio-198517"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default = "vm_instance_keypair/gcloud_instance_key.pub"
}
```
Please note that in the futre I will incoperate the deafult arguments such as ```"smart-radio-198517"``` into the runme script via variables so that the infrastructure can be provisioned via 2 script

## Overall Load balancer archetechture 
The overall HTTP(S) load balancer is described to be

![basic-http-load-balancer](https://user-images.githubusercontent.com/11795947/37981742-6a77da3c-31e6-11e8-9e25-0521f332ddfa.jpg)

more information can be found via the following link https://cloud.google.com/compute/docs/load-balancing/http/

via the runme the following terraform files are run
- static_IP/Secrets.tf
- static_IP/StaticIP.tf
- variables.tf
- Secrets.tf
- Auto_scaler.tf
- Backend.tf
- load_balancer.tf
- Instance_template.tf
- Instance_group_manager.tf

Inorder to create the Load balancer through the following commands 
terraform validate (to validate the files for any errors)
terraform apply -auto-approve (To apply the changes to the infrastructure)

## Terraform file overview
### The instance template (instance_template.tf)
contains the following lines of code 
```machine_type         = "f1-micro"```
The Line of code above allows the instance template to create an f1-micro instance within GCP once run.
On top of this if the server machines hit 40% then the instance template will then be run so that a second f1-micro instance can be added to the instance group which utilises the url-map which is part of the load balancer (more on this in the coming sections).

This therefore means that the objectives
Use f1-micro instances has been achived


On top of this there is a startup script witin the instance template as outlined below

```
    startup-script = <<SCRIPT
sudo apt update 
sudo apt install nginx -y
sudo systemctl start nginx
sudo sed -i '21a foo' /var/www/html/index.nginx-debian.html
sudo sed -i '22a bar' /var/www/html/index.nginx-debian.html
SCRIPT
```

The excerpt above essentially allows for the creation of an nginx server in which the lines foo and bar are added to the index.nginx-debian.html page the reason for this is so that when a GET request is sent to the page 

## Checking to see if the HTTP will acept a GET request to https://Loadbalancer-IP-address and return {foo:bar}
curl --insecure -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://Loadbalancer-IP-address

# Checking for the correct headers
```
curl -I --insecure https://Loadbalancer-IP-address

HTTP/1.1 200 OK
Date: Sun, 16 Oct 2016 23:37:15 GMT
Server: Apache/2.4.23 (Unix)
X-Powered-By: PHP/5.6.24
Connection: close
Content-Type: text/html; charset=UTF-8
```

The above command Above is an example of how we can check all the header for a given ip address
where curl is a tool to transfer data from or to a server and the I argument Fetch the headers only!
as exaplined by this source: https://curl.haxx.se/docs/manpage.html

The reason that we use --insecure is becuase in the runme file a self sighned ssl certificate is created.
The problem with this is that no CA will sighn this particular type of certifcate and this is why we need the --insecure

![header_test_output_and_correction](https://user-images.githubusercontent.com/11795947/37993397-78de3cd6-3206-11e8-93ef-f24bb0b4dfcd.png)

The above picture shows what happens when we do not add the --insecure arguement to the command curl


(insert pics of what happens when using without --insecure)

when we dont use --insecure as the pciture above explain errors sre seen

## Autoscaling
Autoscaling is handled by the Auto_scaler.tf file
in which the following code is run 
(insert code)
The code above (explain what the code above does)
From the code above we can therefore say that the objective (say obective) has been completed
## Security

a series of actions or steps taken in order to achieve a particular end.


