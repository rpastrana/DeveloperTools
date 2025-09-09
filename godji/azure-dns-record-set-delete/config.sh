#!/bin/bash

#Get the subscription name
SUBSCRIPTION_NAME="us-lnhpccplatform-dev"

# Get the resource group name and zone name from the user.
RESOURCE_GROUP_NAME="app-dns-prod-eastus2"
DNS_ZONE_NAME="us-lnhpccplatform-dev.azure.lnrsg.io"

# Get the keyword to select the dns record sets.
# This should be the common string in all of the record names you want to delete.
# Examples: hpcc, hpcc2, play
KEYWORD="hpcc2"

# Types of DNS record sets
RECORD_TYPES=("a" "txt")