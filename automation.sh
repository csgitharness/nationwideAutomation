## Variables
REFERENCE_APPLICATION="GoldenTemplateApplication"
INPUT_APPLICATION=""
INPUT_SERVICE=""
PROD_NAMESPACE=""
TEST_NAMESPACE=""

#LDAP Group.. future




fn_create_application(){
## Copy the Application Template
cd Setup/Applications/

echo "Creating the application directory"
mkdir $INPUT_APPLICATION

echo "Copying content of template application into new application"
cp -a GoldenTemplateApplication/. $INPUT_APPLICATION

echo "created the new application"
}

fn_create_service(){
## cd into the service and rename the service folder
echo "Creating the service within the Application"
cd $INPUT_APPLICATION/Services 
mv referenceNativeK8sSvc $INPUT_SERVICE 
cd $INPUT_SERVICE

}

fn_create_environment(){

## cd into the environment and edit the namespace
cd ../..

cd Environments/prod
ls
sleep 5

echo "Modifying namespace for prod environment"

# Add a for loop to iterate if name = namespace tweak the value
yq w Index.yaml 'variableOverrides[0].value' ${PROD_NAMESPACE} --inplace 

cd ../..
pwd

echo "Modifying namespace for test environment"
cd Environments/test
ls
sleep 5


yq w Index.yaml 'variableOverrides[0].value' ${TEST_NAMESPACE} --inplace


}



fn_edit_pipeline_service() {

cd ../..

cd Pipelines

ls 
## Copy pipeline and tweak it
echo "editting Test Environment Stage of Pipeline"
sleep 5

## yq see how to parse a list or an array 

yq w Reference\ Test\ to\ Prod\ With\ Approval.yaml 'pipelineStages.[0].workflowVariables[2].value' $INPUT_SERVICE --inplace

echo "editting Prod Environment Stage of Pipeline"
sleep 5

yq w Reference\ Test\ to\ Prod\ With\ Approval.yaml 'pipelineStages.[2].workflowVariables[2].value' $INPUT_SERVICE --inplace

}






###### MAIN #####
echo "****** Generating a new Harness Application *******"
echo "Usage: <Application_Name> <Service_Name> <PROD_Namespace> <TEST_Namespace>"


# Summary of what was created Manifest fiels, application name, service name 

if [ -d "Setup" ]; then
  if [ -d "Setup/Applications/$REFERENCE_APPLICATION" ]; then
    INPUT_APPLICATION=$1
    INPUT_SERVICE=$2
    PROD_NAMESPACE=$3
    TEST_NAMESPACE=$4

    echo "Creating application"
    fn_create_application

    echo "Creating Service"
    fn_create_service

    echo "Creating Environment"
    fn_create_environment

    echo "Creating Pipeline"
    fn_edit_pipeline_service
  else 
    echo "Reference Application is needed to execute the script"
  fi
else 
  echo "Script needs to be executed in the setup directory"
fi







