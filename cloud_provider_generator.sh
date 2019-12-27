
CLOUD_PROVIDER_NAME=""
SERVICE_ACCOUNT=""
ENV_TYPE=""
APP_NAME=""

#prod_namespace
#test_namespace 
# add app name for scope - appFilter section

fn_cloud_provider(){
cd Setup/Cloud\ Providers/

touch $CLOUD_PROVIDER_NAME.yaml 

cp  Namespace\ dpt\ -\ Prod\ Cluster\ --\ referenceCloudProvider.yaml $CLOUD_PROVIDER_NAME.yaml 

echo "serviceAccount input"
yq w $CLOUD_PROVIDER_NAME.yaml 'serviceAccountToken' $SERVICE_ACCOUNT --inplace

echo "Selecting the application to scope to the cloud provider"
yq w $CLOUD_PROVIDER_NAME.yaml 'usageRestrictions.appEnvRestrictions.[0].appFilter.entityNames[0]' $APP_NAME --inplace

echo "Cloud Provider Environment Scoping Restrictions for the application"
echo "PROD or NON_PROD"
ls
pwd
yq w $CLOUD_PROVIDER_NAME.yaml 'usageRestrictions.appEnvRestrictions.[0].envFilter.filterTypes[0]' $ENV_TYPE --inplace
}

### MAIN ####

CLOUD_PROVIDER_NAME=$1
SERVICE_ACCOUNT=$2
APP_NAME=$3
ENV_TYPE=$4

echo "Creating Cloud Provider"
echo "Usage: ./cloud_provider_generator.sh <CLOUD_PROVIDER_NAME> <SERVICE_ACCOUNT> <APP_NAME> <ENV_TYPE> "
fn_cloud_provider