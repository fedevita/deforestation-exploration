param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "import", "report")]
    [string]$Profile
)

# Function to print the possible values for the profile parameter
function PrintProfileOptions {
    Write-Host "Possible values for -Profile are: start, import, report"
}

# Check if the parameter is provided and valid
if ($PSCmdlet.MyInvocation.BoundParameters["Profile"]) {
    # Command to start Docker Compose with the specified profile
    $composeCommand = "docker-compose --profile $Profile up -d"

    # Execute the command
    Invoke-Expression $composeCommand
} else {
    # Print the possible values for the profile parameter
    PrintProfileOptions
}
