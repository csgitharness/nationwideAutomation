#!/bin/bash

### Variables ###
CLOUD_PROVIDER_NAME=$1
MASTER_URL=$2
APP_NAME=$3
ENV_TYPE=$4

INPUT_SERVICE=$5
PROD_NAMESPACE=$6
TEST_NAMESPACE=$7

### MAIN ###




echo "USAGE: <CLOUD_PROVIDER_NAME> <MASTER_URL> <APP_NAME> <ENV_TYPE> <INPUT_SERVICE> <PROD_NAMESPACE> <TEST_NAMESPACE>"

if [ $# -lt 7 ]; then
echo "ERROR: Not enough arguments"
echo "USAGE: <CLOUD_PROVIDER_NAME> <MASTER_URL> <APP_NAME> <ENV_TYPE> <INPUT_SERVICE> <PROD_NAMESPACE> <TEST_NAMESPACE>"
exit 0
fi

echo "INFO: Creating Cloud Provider"
echo "INFO: Running Cloud Provider Script"
./cloud_provider_generator.sh $1 $2 $3 $4

sleep 5 


echo "INFO: Creating the Application"
echo "INFO: Running Application automation script"
./automation.sh $3 $5 $6 $7


echo "INFO: DONE"

