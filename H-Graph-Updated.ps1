
# Load required modules
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Authentication
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement

# Connect to services
Connect-ExchangeOnline
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.AccessAsUser.All", "UserAuthenticationMethod.ReadWrite.All", "Mail.ReadWrite"

# Prompt for user input
$userUPN = Read-Host "Enter the User Principal Name (e.g., jdoe@yourdomain.bc.ca)"
$samAccountName = Read-Host "Enter the SAM Account Name (e.g., jdoe)"

# Variables
$logPath = "C:\Scripts\Offboarding\Logs"
$logFile = Join-Path $logPath "$samAccountName-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$offboardedOU = "OU=OffBoarded Users,OU=UserOU,DC=msad,DC=yourdomain,DC=bc,DC=ca"
$smtpTo = "ITRequests@yourdomain.bc.ca"
$smtpFrom = "someone@yourdomain.bc.ca"
$smtpServer = "smtp.office365.com"

# Ensure log directory exists
if (!(Test-Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath
}

function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

try {
    Log "Starting offboarding for $userUPN"

    # 1. Generate random secure password
    Add-Type -AssemblyName System.Web
$securePassword = -join ((65..90) + (97..122) + (48..57) + (33..47) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    $secureString = ConvertTo-SecureString -AsPlainText $securePassword -Force
    Set-ADAccountPassword -Identity $samAccountName -NewPassword $secureString -Reset
    Log "Password reset to a secure random value"

    # 2. Disable on-prem AD account
    Disable-ADAccount -Identity $samAccountName
    Log "On-prem AD account disabled"

    # 3. Capture and log source OU
    $user = Get-ADUser -Identity $samAccountName
    $sourceOU = ($user.DistinguishedName -split ',OU=')[1]
    Log "User's source OU: $sourceOU"

    # 4. Move to OffBoarded OU
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $offboardedOU
    Log "User moved to OffBoarded Users OU"

Set-ADUser -Identity $samAccountName -Replace @{msExchHideFromAddressLists=$true}
Set-ADUser -Identity $samAccountName -Clear telephoneNumber
Log "Set msExchHideFromAddressLists to true and hidden from global address lists and phone number removed"

    # 5. Remove Microsoft 365 licenses
    $userId = (Get-MgUser -UserId $userUPN).Id
    $assignedLicenses = (Get-MgUserLicenseDetail -UserId $userId).SkuId
    if ($assignedLicenses) {
        Set-MgUserLicense -UserId $userId -AddLicenses @() -RemoveLicenses $assignedLicenses
        Log "Microsoft 365 licenses removed"
    }

    # 6. Convert mailbox to shared
    Set-Mailbox -Identity $userUPN -Type Shared
    Log "Mailbox converted to shared"

    
# 7. Remove MFA methods
Get-MgUserAuthenticationMethod -UserId $userId |
ForEach-Object {
    switch ($_.PSObject.Properties["@odata.type"].Value) {
        "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" {
            Remove-MgUserAuthenticationMicrosoftAuthenticatorMethod -UserId $userId -MicrosoftAuthenticatorAuthenticationMethodId $_.Id
        }
        "#microsoft.graph.fido2AuthenticationMethod" {
            Remove-MgUserAuthenticationFido2Method -UserId $userId -Fido2AuthenticationMethodId $_.Id
        }
        "#microsoft.graph.phoneAuthenticationMethod" {
            Remove-MgUserAuthenticationPhoneMethod -UserId $userId -PhoneAuthenticationMethodId $_.Id
        }
        "#microsoft.graph.temporaryAccessPassAuthenticationMethod" {
            Remove-MgUserAuthenticationTemporaryAccessPassMethod -UserId $userId -TemporaryAccessPassMethodId $_.Id
        }
        "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" {
            Remove-MgUserAuthenticationWindowsHelloForBusinessMethod -UserId $userId -WindowsHelloForBusinessAuthenticationMethodId $_.Id
        }
    }
}
Log "MFA methods removed"


    # 8. Revoke sessions
    Revoke-MgUserSignInSession -UserId $userId
    Log "Azure AD sessions revoked"

    # 9. Remove phone numbers
    Update-MgUser -UserId $userId -MobilePhone $null -BusinessPhones @()
    Log "Phone numbers removed"

    # 10. Remove from all Azure AD groups
    Get-MgUserMemberOf -UserId $userId | ForEach-Object {
        if ($_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.group") {
            Remove-MgGroupMemberByRef -GroupId $_.Id -DirectoryObjectId $userId
        }
    }
    Log "Removed from all Azure AD groups"

    # 11. Hide from GAL
    Set-Mailbox -Identity $userUPN -HiddenFromAddressListsEnabled $true
    Log "User hidden from Global Address List"

    # 12. Remove enterprise applications
    Get-MgUserAppRoleAssignment -UserId $userId | ForEach-Object {
        Remove-MgUserAppRoleAssignment -UserId $userId -AppRoleAssignmentId $_.Id
    }
    Log "Enterprise applications removed"

    # 13. Send notification
    $body = "User $userUPN has been offboarded successfully. Log file: $logFile"
    Send-MailMessage -To $smtpTo -From $smtpFrom -Subject "User Offboarding Complete: $userUPN" -Body $body -SmtpServer $smtpServer
    Log "Notification sent to IT"

    Log "Offboarding completed successfully for $userUPN"

} catch {
    Log "Error: $_"
    throw
}
