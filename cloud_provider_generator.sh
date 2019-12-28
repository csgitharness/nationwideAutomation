#!/bin/bash

CLOUD_PROVIDER_NAME=""
MASTER_URL=""
SERVICE_ACCOUNT="changeMe"
ENV_TYPE=""
APP_NAME=""



fn_cloud_provider(){
cd Setup/Cloud\ Providers/

touch $CLOUD_PROVIDER_NAME.yaml 

cp  Namespace\ dpt\ -\ Prod\ Cluster\ --\ referenceCloudProvider.yaml $CLOUD_PROVIDER_NAME.yaml 

echo "INFO: serviceAccount input"
yq w $CLOUD_PROVIDER_NAME.yaml 'masterUrl' $MASTER_URL --inplace

echo "INFO: Selecting the application to scope to the cloud provider"
yq w $CLOUD_PROVIDER_NAME.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.entityNames[0]' $APP_NAME --inplace

echo "INFO: Cloud Provider Environment Scoping Restrictions for the application"
echo "OPTIONS: PROD or NON_PROD"
yq w $CLOUD_PROVIDER_NAME.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' $ENV_TYPE --inplace
}

fn_summary_creation() {
echo "INFO: Summary of Cloud Provider Creation\n"
cat $CLOUD_PROVIDER_NAME.yaml

}

### MAIN ####
if [ $# -lt 4 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: ./cloud_provider_generator.sh <CLOUD_PROVIDER_NAME> <MASTER_URL> <APP_NAME> <ENV_TYPE> "
exit 0
fi

if [ -d "Setup" ]; then 
    CLOUD_PROVIDER_NAME=$1
    MASTER_URL=$2
    APP_NAME=$3
    ENV_TYPE=$4
    echo "INFO: Creating Cloud Provider"
    fn_cloud_provider
else 
  echo "ERROR: No Setup Directory Found"
fi

fn_summary_creation