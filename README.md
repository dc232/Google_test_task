# Introduction
This project is designed to build a load balancer through terraform orchestration and also allows for the management of Google VM’s via external interface IP address through Ansible via gce.ini and gce.py files.

It should be known that I have had only 1 week to get myself familiar with GCP and its concepts and I am very much a novice when it comes to GCP.

However I have not let this deter me from attempting to complete the project.

The runme and Ansible scripts included in this project have been designed with Ubuntu 16.04 in mind

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
          - Creates a self signed certifcate for use with the load balancer
          - Uses the Variable ```COMPUTED_IP_ADDRESS_FROM_TERRAFORM_TFSTATE``` to grab the IP address of the Global load balancer so that it can be used in the forwarding rules
     
     1. The runme file also executes the Ansible file to install 
        - python-pip
        - Python
        - Python3
        - Ansible
        - apache-libcloud (GCE dynamic inventory plugin)
 
3. Move the newly created account.json file to the project directory (Google_test_task) and also to the static_IP/ folder.

4. Ensure that you have set the variables for the static_IP/Secrets.tf to the same values as that of Secrets.tf in the main project folder.
     1.  To do this
         - Run the command ```cat variables.tf``` in the main project folder (see section marked Terraform variable setup) and copy the information accordingly to the file marked static_IP/Secrets.tf

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

More information can be found via the following link https://cloud.google.com/compute/docs/load-balancing/http/

via the runme the following terraform files are run
- static_IP/Secrets.tf
- static_IP/StaticIP.tf
- variables.tf
- Secrets.tf
- Auto_scaler.tf
- load_balancer.tf
- Instance_template.tf
- Instance_group_manager.tf

Inorder to create the Load balancer through the following commands 
- terraform validate (to validate the files for any errors)
- terraform apply -auto-approve (To apply the changes to the infrastructure)

### Secrets.tf 
- Finds and uses the account.json file
- Sets the Project name and Region

### static_IP/StaticIP.tf
- Runs the resource google_compute_global_address and sets a global static IP address for the load balancer

### variables.tf
- Sets the Variables of the overall project (see section marked Terraform variable setup for more details)

### Auto_scaler.tf
- Creates the autoscaler (see section marked Autoscaling for more details)

### load_balancer.tf
- Creates the load balancer through using the diffrent resources explained below

### google_compute_global_forwarding_rule resource
- provides a single global IPv4 or IPv6 address that you can use in DNS records for your site.

- Global forwarding rules also route traffic by IP address, port, and protocol to a load balancing target proxy, which in turn forwards the traffic to an instance group containing your virtual machine instances.

- For more information see source: https://cloud.google.com/compute/docs/load-balancing/http/global-forwarding-rules

The reason why the static IP address is created 1st is becuase if a ephemeral IP is used i.e an Ip address that is created by Google Network Services. It would be difficult to incoperate this information in the certifactes created by the runme file as a common name needs to be defined when the self sighned certifcates are created and uploaded via the resource google_compute_ssl_certificate (more on this resource in the following sections).

As 1 IP address is being used Google also say that

Note: SSL certificate resources are not used on individual VM instances. On an instance, install the normal SSL certificate as described in your application documentation. SSL certificate resources are used only with load balancing proxies such as a target HTTPS proxy or target SSL proxy. See that documentation for when and how to use SSL certificate resources.

For more information see source: https://cloud.google.com/compute/docs/load-balancing/http/ssl-certificates

### google_compute_target_https_proxy
- Target proxies are referenced by one or more global forwarding rules. In the case of HTTP(S) load balancing, proxies route incoming requests to a URL map.

- For more information see source: https://cloud.google.com/compute/docs/load-balancing/http/target-proxies

### google_compute_ssl_certificate
- Uploads the created self sighned from the runme script which creates an unencrypted private key and a certificate generated using that key so that it can be used by the load balancer via the target proxy

As mentioned in the documentation
- To use HTTPS or SSL load balancing, you must create at least one SSL certificate that can be used by the target proxy for the load balancer. You can configure the target proxy with up to ten SSL certificates. For each SSL certificate, you first create an SSL certificate resource. The SSL certificate resource contains the certificate information.

- For more information see source: https://cloud.google.com/compute/docs/load-balancing/http/ssl-certificates

### google_compute_url_map
- The URL map allows for the direction of traffic based on the incoming URL
- As there is no host rule (i.e domain to be redirected) then all then this means that all hosts will use the same path matcher, 
(the path matcher is essentially a folder on the backend server so if you had a domain such as www.vinsonjewellers.com/videos the patch matcher if set to /video would direct traffic to the /video folder in the instance defined by the backend service)
- As we do not have any path matchers set as it is not needed for this task the default path matcher is used which is /*. 

This means that every match is sent to the default service which is defined as the backend

- Grater granularity can be achived through using path rule, theese are rules with route the traffic to a particular destination of the backend such as /video/hd/* this would be a reference to match any content witin the directory /video/hd/ as stated via the GET request to the URL should be redirected to the backend insatnce hosting that content

- An example from the source

![url-map-detail-1 1](https://user-images.githubusercontent.com/11795947/38011516-9c34d1f0-3255-11e8-99d6-6136d944d0ec.png)

- For more information see source: https://cloud.google.com/compute/docs/load-balancing/http/url-map

### google_compute_backend_service
- A Backend Service defines a group of virtual machines that will serve traffic for load balancing
- An HTTP(S) load balancing backend service is a centralized service for managing backends, which in turn manage instances that handle user requests. You configure your load balancing service to route requests to your backend service. The backend service in turn knows which instances it can use, how much traffic they can handle, and how much traffic they are currently handling. In addition, the backend service monitors health checking and does not send traffic to unhealthy instances.

- For more information see source https://cloud.google.com/compute/docs/load-balancing/http/backend-service

### google_compute_http_health_check
- Manages an HTTP health check within GCE. This is used to monitor instances behind load balancers. Timeouts or HTTP errors cause the instance to be removed from the pool
- Google Cloud Platform (GCP) health checks determine whether instances are "healthy" and available to do work. This document describes using health checks with load balancing.
- in the case of the script there is   ```request_path       = "/"```  in other words this resource checks that the path / is still up for theese instances
 - For more information see source: https://cloud.google.com/compute/docs/load-balancing/health-checks#legacy_health_checks

### google_compute_target_pool

### google_compute_instance_group_manager




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
```

The above command Above is an example of how we can check all the header for a given ip address
where curl is a tool to transfer data from or to a server and the I argument Fetches the headers only!
as exaplined by this source: https://curl.haxx.se/docs/manpage.html

The reason that we use --insecure is becuase in the runme file a self signed ssl certificate is created.
The problem with this is that no CA will sign this particular type of certifcate and this is why we need the --insecure

![header_test_output_and_correction](https://user-images.githubusercontent.com/11795947/37993397-78de3cd6-3206-11e8-93ef-f24bb0b4dfcd.png)

The above picture shows what happens when we do not add the --insecure arguement to the command curl. As can be seen the certifcate verfication check fails as the certifcate is seen to be untrusted.

A posible soultion locally for this can be found from this source: https://stackoverflow.com/questions/21181231/server-certificate-verification-failed-cafile-etc-ssl-certs-ca-certificates-c 
I am still reaserching this part via the link, however it is more practical to associate a hostname with the load balancer and then get the the certifcate signed by a CA such as lets encrypt.

The self signed certifcate code can be seen via the function ```certifcate_creation``` an excert of which can be seen below

```
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
```

From the screen shot above once we add the --insecure argument we see that we get the reponse 200 OK which means that the nginx page is reachable and viewable

It is therefore possible to suggest that the correct headers are being returned

## Autoscaling
Autoscaling is handled by the Auto_scaler.tf file
in which the following code is run

```
resource "google_compute_autoscaler" "foobar" {
  name   = "scaler"
  zone   = "${var.region_zone}"
  target = "${google_compute_instance_group_manager.foobar.self_link}"

  autoscaling_policy = {
    max_replicas    = 2
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.4
    }
  }
}
```

The code above executes an autoscaling policy in which the minimum number of servers in the autoscaling group in this case in the instance group "foobar" is 1 and when the cpu on the instance hits 40% another f1-micro instance is created via the instance template.
The cooldown_period period option is the wait between a change in the cpu utilization. This is double the time the instances take to start up which is usually 30 seconds.

From the code above we can therefore say that the following objectives have been completed
- Server machines scale at 40% cpu has been completed
- Minimum size of server auto-scaling group = 1 and max = 2

## Security

a series of actions or steps taken in order to achieve a particular end.


