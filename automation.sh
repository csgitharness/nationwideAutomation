## Variables
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
mkdir $INPUT_SERVICE 
cd $INPUT_SERVICE

echo "generating service files for the new service"
fn_generate_k8s_service_files

}

fn_generate_k8s_service_files(){
echo "creating the service index.yaml"
touch index.yaml
cat << EOF  > index.yaml 
harnessApiVersion: '1.0'
type: SERVICE
artifactType: DOCKER
deploymentType: KUBERNETES
EOF

echo "creating the manifest directory"
mkdir Manifests
cd Manifests

echo "Creating the Manifests/index.yaml"
touch index.yaml 
cat << EOF  > index.yaml 
harnessApiVersion: '1.0'
type: APPLICATION_MANIFEST
gitFileConfig:
  branch: master
  connectorName: APRMID - App Name - k8s Manifests -- Example RegulatedNativeK8sManifests
  filePath: manifests
  useBranch: true
storeType: Remote
EOF


}

fn_create_environment(){
## cd into the environment and edit the namespace
cd ../../..

cd Environments/prod

echo "Modifying namespace for prod environment"
touch update_prod.yaml 
cat << EOF  > update_prod.yaml 
harnessApiVersion: '1.0'
type: ENVIRONMENT
configMapYamlByServiceTemplateName: {}
description: This is a reference Prod environment
environmentType: PROD
variableOverrides:
- name: namespace
  value: ${PROD_NAMESPACE}
  valueType: TEXT
EOF

cp -f update_prod.yaml  index.yaml
rm -rf update_prod.yaml

cd ../..
pwd

echo "Modifying namespace for test environment"
cd Environments/test
touch update_test.yaml 
cat << EOF  > update_test.yaml 
harnessApiVersion: '1.0'
type: ENVIRONMENT
configMapYamlByServiceTemplateName: {}
description: This is a reference Prod environment
environmentType: NON_PROD
variableOverrides:
- name: namespace
  value: ${TEST_NAMESPACE}
  valueType: TEXT
EOF

cp -f update_test.yaml  index.yaml
rm -rf update_test.yaml



}



fn_edit_pipeline_service() {
## Change the Service name in the Pipeline
cd ../..

cd Pipelines
## Copy pipeline and tweak it

touch dev_pipeline.yaml
cat << EOF > dev_pipeline.yaml 
harnessApiVersion: '1.0'
type: PIPELINE
description: This is a reference pipeline with a test deploy, followed by a prod deploy after approval is granted.
pipelineStages:
- type: ENV_STATE
  name: Test Deployment
  parallel: false
  skipCondition:
    type: DO_NOT_SKIP
  stageName: STAGE 1
  workflowName: Reference Rolling Deployment
  workflowVariables:
  - entityType: INFRASTRUCTURE_DEFINITION
    name: InfraDefinition_Kubernetes
    value: Test
  - entityType: ENVIRONMENT
    name: Environment
    value: test
  - entityType: SERVICE
    name: Service
    value: ${INPUT_SERVICE}
- type: APPROVAL
  name: Approval 1
  parallel: false
  properties:
    userGroups:
    - 4nl5M5WpSD2uDw5n9iG1bQ
    timeoutMillis: 604800000
    approvalStateType: USER_GROUP
  skipCondition:
    type: DO_NOT_SKIP
  stageName: STAGE 2
- type: ENV_STATE
  name: Prod Deployment
  parallel: false
  skipCondition:
    type: DO_NOT_SKIP
  stageName: STAGE 3
  workflowName: Reference Rolling Deployment
  workflowVariables:
  - entityType: INFRASTRUCTURE_DEFINITION
    name: InfraDefinition_Kubernetes
    value: Prod
  - entityType: ENVIRONMENT
    name: Environment
    value: prod
  - entityType: SERVICE
    name: Service
    value: ${INPUT_SERVICE}
EOF

}






###### MAIN #####
echo "Generating a new Harness Application"
echo "Usage: <Application_Name> <Service_Name> <PROD_Namespace> <TEST_Namespace>"

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