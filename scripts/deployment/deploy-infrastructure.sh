#!/bin/bash

# Marketing Insights Infrastructure Deployment Script
# Usage: ./deploy-infrastructure.sh <environment> <subscription-id> [resource-group-name]

set -e

# Parameters
ENVIRONMENT=$1
SUBSCRIPTION_ID=$2
RESOURCE_GROUP_NAME=${3:-"mi-$ENVIRONMENT-rg"}
LOCATION="East US 2"

# Validation
if [ -z "$ENVIRONMENT" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Usage: ./deploy-infrastructure.sh <environment> <subscription-id> [resource-group-name]"
    echo "Environment should be: dev, test, or prod"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "Environment must be one of: dev, test, prod"
    exit 1
fi

echo "=== Marketing Insights Infrastructure Deployment ==="
echo "Environment: $ENVIRONMENT"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Location: $LOCATION"
echo ""

# Set Azure subscription
echo "Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create resource group if it doesn't exist
echo "Creating resource group if it doesn't exist..."
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --tags Environment="$ENVIRONMENT" Project="Marketing-Insights" ManagedBy="Script"

# Validate Bicep template
echo "Validating Bicep template..."
az deployment group validate \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "./infrastructure/bicep/main.bicep" \
    --parameters "./infrastructure/environments/$ENVIRONMENT.parameters.json"

if [ $? -ne 0 ]; then
    echo "Template validation failed. Please check the template and parameters."
    exit 1
fi

echo "Template validation successful!"

# Deploy infrastructure
echo "Deploying infrastructure..."
DEPLOYMENT_NAME="mi-$ENVIRONMENT-deployment-$(date +%Y%m%d-%H%M%S)"

az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DEPLOYMENT_NAME" \
    --template-file "./infrastructure/bicep/main.bicep" \
    --parameters "./infrastructure/environments/$ENVIRONMENT.parameters.json" \
    --verbose

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Deployment Successful ==="
    echo "Deployment Name: $DEPLOYMENT_NAME"
    echo ""
    
    # Get deployment outputs
    echo "=== Deployment Outputs ==="
    az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs \
        --output table
    
    echo ""
    echo "=== Next Steps ==="
    echo "1. Update GitHub Secrets with the output values"
    echo "2. Configure application settings in the Function App"
    echo "3. Deploy the application code using GitHub Actions"
    echo "4. Run database migrations"
    echo ""
else
    echo "Deployment failed. Check the Azure portal for details."
    exit 1
fi