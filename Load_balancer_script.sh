###################################
#Global Variables
###################################
NAME_OF_URL_MAP="test"
BACK_END_SERVICE="my-backend"
NAME_OF_TARGET_PROXY="test-target-proxy1"
SSL_CERT_NAME="test"
FORWARDING_RULE_IP_ADDR="35.184.132.197"

GCLOUD_SDK_INSTALL () {
    
}


loadbalancer () {
cat << EOF 
###################################
Creating load balancer 
in accordance with https://cloud.google.com/compute/docs/load-balancing/http/
###################################
EOF

sleep 2

cat << EOF 
###################################
creating Global Forwarding Rules
###################################
EOF
sleep 2

gcloud compute forwarding-rules create testforwardingrule --address $FORWARDING_RULE_IP_ADDR --ip-protocol TCP --ports=443-443 --target-https-proxy $NAME_OF_TARGET_PROXY

cat << EOF 
###################################
creating Target Proxy
###################################
EOF
sleep 2

gcloud compute target-https-proxies create $NAME_OF_TARGET_PROXY --url-map $NAME_OF_URL_MAP --ssl-certificates $SSL_CERT_NAME

cat << EOF 
###################################
creating URL map
Needed for path selection
###################################
EOF

sleep 2

gcloud compute url-maps create $NAME_OF_URL_MAP --default-service $BACK_END_SERVICE

}



cat << EOF
###################################
This script is desighned to
1. Install Gcloud suite
2. Configure a HTTPS load balancer 
###################################
EOF

sleep 2

