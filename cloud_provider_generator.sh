
CLOUD_PROVIDER_NAME=""
SERVICE_ACCOUNT=""

#prod_namespace
#test_namespace 
# add app name for scope - appFilter section

fn_cloud_provider(){
touch $CLOUD_PROVIDER_NAME.yaml 
cat << EOF  > ${CLOUD_PROVIDER_NAME}.yaml  
harnessApiVersion: '1.0'
type: KUBERNETES_CLUSTER
masterUrl: https://35.247.123.240
serviceAccountToken: ${SERVICE_ACCOUNT}
skipValidation: false
usageRestrictions:
  appEnvRestrictions:
  - appFilter:
      filterType: ALL
    envFilter:
      filterTypes:
      - PROD
  - appFilter:
      filterType: ALL
    envFilter:
      filterTypes:
      - NON_PROD
useKubernetesDelegate: false
EOF

}

### MAIN ####

 cd Setup/Cloud\ Providers/

CLOUD_PROVIDER_NAME=$1
SERVICE_ACCOUNT=$2

echo "Creating Cloud Provider"
echo "Usage: ./cloud_provider_generator.sh <CLOUD_PROVIDER_NAME> <SERVICE_ACCOUNT> "
fn_cloud_provider