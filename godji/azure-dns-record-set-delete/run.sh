#!/bin/bash

#Include config.sh
source ./config.sh

# #Get the subscription name
# echo "Enter the subscription name:"
# read SUBSCRIPTION_NAME

# # Get the resource group name and zone name from the user.
# echo "Enter the resource group name:"
# read RESOURCE_GROUP_NAME
# echo "Enter the zone name:"
# read DNS_ZONE_NAME

# # Get the keyword to select the dns record sets.
# # This should be common string in all the record names you want to delete.
# # Examples: hpcc, hpcc2, play
# echo "Enter the keyword to select a specific record set:"
# read KEYWORD

# # Types of DNS record sets
# RECORD_TYPES=("A" "TXT")

# Set the subscription
az account set --name $SUBSCRIPTION_NAME

# Initialize the array
RECORD_SETS=()

# Find the records that end with the exact keyword
find-records () {
    # Use process substitution to capture the output of the pipeline and set the RECORD_SETS array.
    while IFS= read -r record; do
        RECORD_SETS+=("$record")
    done < <(az network dns record-set list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --zone-name "$DNS_ZONE_NAME" | grep -o '"name": "[^"]*"' | \
        grep -w "${KEYWORD}" | \
        awk -F'"' '{print $4}')
}

# Delete the record sets
delete-records () {
    if [ ${#RECORD_SETS[*]} -gt 0 ];then
        echo "The following list of records will be deleted:"
        echo ${RECORD_SETS[*]}
        echo "Are you sure you want to perform this operation? (y/n):"
        read confirm
    else
        echo "No records found."
        abort
    fi
    
    if [ ${#RECORD_SETS[*]} -gt 0 ] && [ $confirm == 'y' ];then
        for type in "${RECORD_TYPES[@]}"; do
        # Delete the record sets.
            for record_set in "${RECORD_SETS[@]}"; do
                echo "az network dns record-set $type delete \
                    --name "$record_set" \
                    --zone-name "$DNS_ZONE_NAME" \
                    --resource-group "$RESOURCE_GROUP_NAME""

                az network dns record-set $type delete \
                    --name "$record_set" \
                    --zone-name "$DNS_ZONE_NAME" \
                    --resource-group "$RESOURCE_GROUP_NAME" \
                    --yes
            done
        done

        deleted
    fi
}

# Print a success message.
deleted () {
    echo "Successfully deleted the DNS record sets."
}

# Print an abort message
abort () {
    echo "The operation has been aborted."
}

# Call the functions
find-records
delete-records