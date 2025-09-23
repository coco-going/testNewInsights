#!/bin/bash

# Database Setup Script for Marketing Insights
# Usage: ./run-database-setup.sh <environment>

set -e

ENVIRONMENT=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: ./run-database-setup.sh <environment>"
    echo "Environment should be: dev, test, or prod"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
    echo "Environment must be one of: dev, test, prod"
    exit 1
fi

echo "=== Marketing Insights Database Setup ==="
echo "Environment: $ENVIRONMENT"
echo ""

# Get database connection details from Azure Key Vault or environment variables
if [ -n "$SQL_CONNECTION_STRING" ]; then
    CONNECTION_STRING="$SQL_CONNECTION_STRING"
elif [ -n "$KEYVAULT_URI" ]; then
    echo "Retrieving connection string from Key Vault..."
    CONNECTION_STRING=$(az keyvault secret show --vault-name "mi-$ENVIRONMENT-kv" --name "SqlConnectionString" --query value --output tsv)
else
    echo "Error: SQL_CONNECTION_STRING or KEYVAULT_URI environment variable must be set"
    exit 1
fi

# Extract server and database from connection string
SERVER=$(echo "$CONNECTION_STRING" | sed -n 's/.*Server=tcp:\([^,]*\),.*/\1/p')
DATABASE=$(echo "$CONNECTION_STRING" | sed -n 's/.*Initial Catalog=\([^;]*\);.*/\1/p')

echo "Database Server: $SERVER"
echo "Database Name: $DATABASE"
echo ""

# Function to execute SQL script
execute_sql() {
    local script_file=$1
    local description=$2
    
    echo "Executing: $description"
    echo "Script: $script_file"
    
    if [ ! -f "$script_file" ]; then
        echo "Error: Script file not found: $script_file"
        return 1
    fi
    
    # Use Azure CLI to execute SQL (requires Azure login)
    if command -v az &> /dev/null && az account show &> /dev/null; then
        echo "Using Azure CLI for SQL execution..."
        az sql db query \
            --server "$SERVER" \
            --database "$DATABASE" \
            --auth-type ActiveDirectoryIntegrated \
            --file "$script_file"
    else
        echo "Azure CLI not available or not logged in. Using sqlcmd..."
        # Fallback to sqlcmd if available
        if command -v sqlcmd &> /dev/null; then
            sqlcmd -S "$SERVER" -d "$DATABASE" -G -i "$script_file"
        else
            echo "Error: Neither Azure CLI nor sqlcmd is available"
            return 1
        fi
    fi
    
    echo "✓ Completed: $description"
    echo ""
}

# Check if database exists and is accessible
echo "Testing database connection..."
if az sql db query --server "$SERVER" --database "$DATABASE" --auth-type ActiveDirectoryIntegrated --query "SELECT 1 as test" &> /dev/null; then
    echo "✓ Database connection successful"
else
    echo "✗ Database connection failed"
    exit 1
fi
echo ""

# Execute database setup scripts in order
echo "Setting up database schema and data..."

# 1. Create schema
execute_sql "$SCRIPT_DIR/database-schema.sql" "Creating database schema"

# 2. Create initial data (if environment is dev)
if [ "$ENVIRONMENT" = "dev" ]; then
    if [ -f "$SCRIPT_DIR/sample-data.sql" ]; then
        execute_sql "$SCRIPT_DIR/sample-data.sql" "Inserting sample data"
    fi
fi

# 3. Run environment-specific setup
ENV_SCRIPT="$SCRIPT_DIR/database-setup-$ENVIRONMENT.sql"
if [ -f "$ENV_SCRIPT" ]; then
    execute_sql "$ENV_SCRIPT" "Running environment-specific setup ($ENVIRONMENT)"
fi

# 4. Update version tracking
VERSION_SCRIPT="$SCRIPT_DIR/update-version.sql"
if [ -f "$VERSION_SCRIPT" ]; then
    execute_sql "$VERSION_SCRIPT" "Updating database version"
fi

echo "=== Database Setup Complete ==="
echo "Environment: $ENVIRONMENT"
echo "Database: $DATABASE"
echo "Timestamp: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""
echo "Next steps:"
echo "1. Verify application connection to database"
echo "2. Test API endpoints"
echo "3. Run integration tests"
echo ""