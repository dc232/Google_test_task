# Introduction
This project is designed to build a load balancer through terraform orchestration and also allows for the management of Google VM’s via external interface IP address through Ansible via gce.ini and gce.py files.

It should be known that I have had only 1 week to get myself familiar with GCP and its concepts and I am very much a novice when it comes to GCP.

However I have not let this deter me from attempting to complete the project.

## The Requirements of Project

 - [x] Create a new Google Platform Project 
 - [x] Use f1-micro instances
 - [ ] Ensure the enviroment is completely secure
 - [x] Use Nginx/Apache or SimpleHTTPServer
 - [x] Return the correct headers
 - [x] If a server dies rebuild and re-add to the LB
 - [x] Minimum size of server auto-scaling group 1 and max 2
 - [x] IAM Acess

## Getting started
1. Sign into google cloud and create a project
2. Type in the search bar API and services --> API library --> Google Compute Engine API
3. Enable the Google Compute Engine API for the project
4. Create a service account on google cloud
      1. Once an account has been created go to the API Dashboard this can be done by typing API into the search bar and then selecting Credentials APIs & Services
      1. Once at the screen click on Create credentials --> Service account key --> Create Service account and then select Compute Engine default service account if avalible if not then click on New service account and then enter a name for the Service account and then click on next, select the role as Compute Engine --> Compute Admin and then click on create. This will then create a .json file save this file as account.json 
5. Move the account.json file to the project directory and also to the  static_IP/ folder
6. The project comes with 2 files, 
      
      
      
   1. Go to link https://cloud.google.com/compute/docs/access/service-accounts for more information about this, in a nutshell this allows for the creation of the account.json file needed to run the project. The account.json file holds information such as the client email address needed for API access to resources such as the Google Compute engine, Project ID so that when the accounts.json file is run it is associated with the correct project and a private key created by Google to ensure access to resources is secure.
   https://support.google.com/cloud/answer/6158857?hl=en
   
   1. 
2.	Git clone https://github.com/dc232/Google_test_task.git



## Loadbalancer
## Autoscaling
## Security
