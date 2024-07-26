#!/bin/bash

# Function to print the possible values for the profile parameter
print_profile_options() {
    echo "Possible values for -profile are: start, import, report"
}

# Check if the parameter is provided and valid
if [ -z "$1" ]; then
    echo "Error: Missing -profile argument."
    print_profile_options
    exit 1
fi

PROFILE=$1

# Validate the profile parameter
case "$PROFILE" in
    start|import|report)
        # Command to start Docker Compose with the specified profile
        docker-compose --profile "$PROFILE" up -d
        ;;
    *)
        echo "Error: Invalid value for -profile."
        print_profile_options
        exit 1
        ;;
esac
