//resource "google_project_iam_policy" "project" {
//  project     = "smart-radio-198517"
//  policy_data = "${data.google_iam_policy.admin.policy_data}"
//}

//data "google_iam_policy" "admin" {
//  binding {
//    role = "roles/compute.networkViewer"

//    members = [
//      "user:leonard.austin@ravelin.com",
//      "user:michel.blankleder@ravelin.com",
//    ]
//  }
//}


#data "google_iam_policy" "admin" {
#  binding {
#    role = "roles/compute.networkViewer"
#    members = [
#      "user:leonard.austin@ravelin.com",
#      "user:michel.blankleder@ravelin.com",
#    ]
#  },

#      role = "roles/compute.viewer"
#      members = [
#      "user:leonard.austin@ravelin.com",
#      "user:michel.blankleder@ravelin.com",
#    ]
#  }




//https://www.terraform.io/docs/providers/google/r/google_project_iam_policy.html
//https://cloud.google.com/iam/docs/overview#concepts_related_identity

//Permissions
//Permissions determine what operations are allowed on a resource. 
//In the Cloud IAM world, permissions are represented in the form of <service>.<resource>.<verb>, for example pubsub.subscriptions.consume.
//where the verb is the action such as create, so in our case this is list
//the resource is the thign we interact with so in this instace it sould be instances within the compute engine
// so an example as listed here would be
//https://cloud.google.com/iam/docs/overview#permissions
//compute.instances.list --> this means that in the policy that we create the identies (the email accounts) only
//have the permissions to list the google compute instances 

// inorder to define the permissions we need to create a policy which says, who can do what to which thing
//they are made up of permissions that are bundled into roles (such as owner, view, editor) 
//which grant acess to resources (cloud platfron, projects, compute engine)
//which are then assighned to identies (google account)
//see https://www.youtube.com/watch?v=96HlT4f2AUU


//turns out that we can add viewer permissions to the users but this will mean that 

//googel compute IAM access via API names https://cloud.google.com/compute/docs/access/iam
//understanding the diffrent roles in google compute engine
//https://cloud.google.com/iam/docs/understanding-roles - there are 3 main roles
//one of which is the viewer which has read only permission actions that preserve the state of the
//resource being assighned



//if run code above "as is" then we are greeted with
//Error: Error applying plan:

//1 error(s) occurred:

//* google_project_iam_policy.project: 1 error(s) occurred:

//* google_project_iam_policy.project: Error retrieving IAM policy for project "smart-radio-198517": googleapi: Error 403: Cloud Resource Manager API has not been used in project smart-radio-198517 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=smart-radio-198517 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry., accessNotConfigured

//Terraform does not automatically rollback in the face of errors.
//Instead, your Terraform state file has been partially updated with
//any resources that successfully completed. Please address the error
//above and apply again to incrementally change your infrastructure.

//this error suggests that inorder to complete the project programatically
//the following API needs to be enabled 
//Cloud Resource Manager API
//Google Compute Engine API
//theese will then allow us to manage the infrasture as needed

//however once the API was enabled the following  was observed


//Error: Error applying plan:

//1 error(s) occurred:

//* google_project_iam_policy.project: 1 error(s) occurred:

//* google_project_iam_policy.project: Error applying IAM policy to project: Error applying IAM policy for project "smart-radio-198517". Policy is &cloudresourcemanager.Policy{AuditConfigs:[]*cloudresourcemanager.AuditConfig(nil), Bindings:[]*cloudresourcemanager.Binding{(*cloudresourcemanager.Binding)(0xc4207be840), (*cloudresourcemanager.Binding)(0xc4207be8a0), (*cloudresourcemanager.Binding)(0xc4207be900)}, Etag:"BwVoEkIj5Yk=", Version:1, ServerResponse:googleapi.ServerResponse{HTTPStatusCode:200, Header:http.Header{"Content-Type":[]string{"application/json; charset=UTF-8"}, "Vary":[]string{"Origin", "X-Origin", "Referer"}, "Date":[]string{"Fri, 23 Mar 2018 12:48:01 GMT"}, "Server":[]string{"ESF"}, "Cache-Control":[]string{"private"}, "X-Frame-Options":[]string{"SAMEORIGIN"}, "X-Content-Type-Options":[]string{"nosniff"}, "X-Xss-Protection":[]string{"1; mode=block"}, "Alt-Svc":[]string{"hq=\":443\"; ma=2592000; quic=51303432; quic=51303431; quic=51303339; quic=51303335,quic=\":443\"; ma=2592000; v=\"42,41,39,35\""}}}, ForceSendFields:[]string(nil), NullFields:[]string(nil)}, error is googleapi: Error 403: The caller does not have permission, forbidden

//Terraform does not automatically rollback in the face of errors.
//Instead, your Terraform state file has been partially updated with
//any resources that successfully completed. Please address the error
//above and apply again to incrementally change your infrastructure.


//despite have the deafult perrmissions applied for API acess

//https://cloud.google.com/iam/docs/granting-changing-revoking-access
//the lbk above suggests that it may be worth having a look at the exisiting policy if one exists through either the API 
//the console or GCLOUD SDK
//via the console odly the permissions can be set i suspect this is becuase I am orchestrtaing this through the owners of the project email account
//which is the equivlant of a root account
//the permissions above would have been granted to the people at ravelin with the ability to see only the compute engine resources and the network resources that are being used
//as a result it may be worht setting the policy and binding it to the users within the console in the intrest of time
//however I will try with GCLOUD sdk to see if there is a programtic way around the issue
// https://cloud.google.com/iam/docs/understanding-roles 
//looks like it could be a roles issue but seems odd as API services has editoral role , but they are seen as prmitive roles, hmmm
//roles/editor	Editor	All viewer permissions and permissions for actions that modify state. .. looks like it should have worked, terraform problem?
//managed to install GCLOUD via https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu
//checking policy via gcloud through 

// once setup up the policy is returned in the same manner as that on google cloud console


//dc@dc-HP-Pavilion-dv7-Notebook-PC:~/Desktop/CICD$ gcloud projects get-iam-policy smart-radio-198517 --format json
//{
//  "bindings": [
//    {
//      "members": [
//        "serviceAccount:821378217086-compute@developer.gserviceaccount.com",
//        "serviceAccount:821378217086@cloudservices.gserviceaccount.com"
//      ],
//      "role": "roles/editor"
//    },
//    {
//      "members": [
//        "user:techspec214@gmail.com"
//      ],
//      "role": "roles/owner"
//    }
//  ],
//  "etag": "BwVoEkIj5Yk=",
//  "version": 1
//}




//when setting the new permission for the users in the console we get 
//the following updated policy which grants acess to view the compute engine and cmopute networking
//resourses needed to complete the project
//this can then be programatically set through 
//the command
//gcloud projects set-iam-policy smart-radio-198517 iam.json
//where iam.json is the updated policy
//it should be known that setting policies incorrectly can lead to lock out
//as mentioed in https://cloud.google.com/iam/docs/granting-changing-revoking-access

//{
//  "bindings": [
//    {
//      "members": [
//        "user:leonard.austin@ravelin.com",
//        "user:michel.blankleder@ravelin.com"
//      ],
//      "role": "roles/compute.networkViewer"
//    },
//    {
//      "members": [
//        "user:leonard.austin@ravelin.com",
//        "user:michel.blankleder@ravelin.com"
//      ],
//      "role": "roles/compute.viewer"
//    },
//    {
//      "members": [
//        "serviceAccount:821378217086-compute@developer.gserviceaccount.com",
//        "serviceAccount:821378217086@cloudservices.gserviceaccount.com"
//      ],
//      "role": "roles/editor"
//    },
//    {
//      "members": [
//        "user:techspec214@gmail.com"
//      ],
//      "role": "roles/owner"
//    }
//  ],
//  "etag": "BwVoFfZOxz0=",
//  "version": 1
//}

//possible explanation as to why IAM acess on terraform does not work
//https://developers.google.com/identity/protocols/OAuth2ServiceAccount?hl=en_GB#delegatingauthority
//but cant be done with regular gmail account
//see screen shot about gsuite


//added IAM permissions through the console