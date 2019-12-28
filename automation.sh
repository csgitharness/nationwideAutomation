#!/bin/bash

## Variables
REFERENCE_APPLICATION="GoldenTemplateApplication"
INPUT_APPLICATION=""
INPUT_SERVICE=""
PROD_NAMESPACE=""
TEST_NAMESPACE=""






fn_create_application(){

echo "INFO: Navigating to the Applications Folder"
cd Setup/Applications/

echo "INFO: Creating the application directory"
mkdir $INPUT_APPLICATION

echo "INFO: Copying content of template application into new application"
cp -a GoldenTemplateApplication/. $INPUT_APPLICATION

echo "INFO: Created the new application"
cd $INPUT_APPLICATION
yq w Index.yaml 'description' $INPUT_APPLICATION --inplace

}

fn_create_service(){
## cd into the service and rename the service folder
echo "INFO: Navigating to Service"
cd ..

echo "INFO: Creating the service within the Application"
cd $INPUT_APPLICATION/Services 
mv referenceNativeK8sSvc $INPUT_SERVICE 

echo "INFO: Navigating to $INPUT_SERVICE"
cd $INPUT_SERVICE 

echo "INFO: Editting the default description to service name"
yq w Index.yaml 'description' $INPUT_SERVICE --inplace

}

fn_create_environment(){

echo "INFO: Navigating to Environments"
cd ../..
cd Environments/prod


echo "INFO: Modifying namespace for prod environment"

# Add a for loop to iterate if name = namespace tweak the value
yq w Index.yaml 'variableOverrides[0].value' ${PROD_NAMESPACE} --inplace 

cd ../..

echo "INFO: Modifying namespace for test environment"
cd Environments/test


yq w Index.yaml 'variableOverrides[0].value' ${TEST_NAMESPACE} --inplace


}



fn_edit_pipeline_service() {

echo "INFO: Navigating to Pipelines"
cd ../..
cd Pipelines


echo "INFO: Editting Test Environment Stage of Pipeline"

## yq see how to parse a list or an array 

yq w Reference\ Test\ to\ Prod\ With\ Approval.yaml 'pipelineStages.[0].workflowVariables[2].value' $INPUT_SERVICE --inplace

echo "INFO: Editting Prod Environment Stage of Pipeline"
yq w Reference\ Test\ to\ Prod\ With\ Approval.yaml 'pipelineStages.[2].workflowVariables[2].value' $INPUT_SERVICE --inplace

}



fn_print_summary() {

echo "INFO: Navigating to Setup\n"
cd ../../../..

echo "INFO: Generating Summary\n"

echo "***** SUMMARY OF APPLICATION *****\n"
cat Setup/Applications/$INPUT_APPLICATION/Index.yaml

echo "\n"

echo "***** SUMMARY OF SERVICE ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Services/$INPUT_SERVICE/Index.yaml

echo "\n"

echo "***** SUMMARY OF SERVICE MANIFEST *****\n"
cat Setup/Applications/$INPUT_APPLICATION/Services/$INPUT_SERVICE/Manifests/Index.yaml

echo "\n"

echo "***** SUMMARY OF Prod ENVIRONMENTS ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Environments/prod/Index.yaml

echo "\n"

echo "***** SUMMARY OF Test ENVIRONMENTS ******\n"
cat Setup/Applications/$INPUT_APPLICATION/Environments/test/Index.yaml

}


###### MAIN #####
echo "****** Generating a new Harness Application *******"

if [ $# -lt 4 ]; then
echo "ERROR: Not enough arguments"
echo "Usage: <Application_Name> <Service_Name> <PROD_Namespace> <TEST_Namespace>"
exit 0
fi

# Summary of what was created Manifest fiels, application name, service name 

if [ -d "Setup" ]; then
  if [ -d "Setup/Applications/$REFERENCE_APPLICATION" ]; then
    INPUT_APPLICATION=$1
    INPUT_SERVICE=$2
    PROD_NAMESPACE=$3
    TEST_NAMESPACE=$4

    echo "INFO: Creating application"
    fn_create_application

    echo "INFO: Creating Service"
    fn_create_service

    echo "INFO: Creating Environment"
    fn_create_environment

    echo "INFO: Creating Pipeline"
    fn_edit_pipeline_service
  else 
    echo "ERROR: Reference Application is needed to execute the script"
  fi
else 
  echo "ERROR: Script needs to be executed in the setup directory"
fi


fn_print_summary




