# O365-on-Prem-AD
Off Boarding Script for O365 users and Hybrid Synced Environment

1) Understanding the scope of the script
Here’s a solid PowerShell-based offboarding script tailored for Office 365 users in a hybrid on-premises Active Directory (AD) environment, based on a well-documented GitHub project:

🔧 Script Overview
The script automates key offboarding tasks such as:

Resets password to a random secure value

Disables the on-prem AD account

Moves user to the designated "OffBoarded Users" OU

Removes Office 365 licenses

Converts mailbox to shared

Removes all MFA methods and revokes sessions

Removes phone number

Removes user from Microsoft Teams and all Azure AD groups

Hides user from the Global Address List

Sends notification to IT via SMTP

Removes all assigned enterprise applications from a user in Azure AD

Logs all actions to: C:\Scripts\Offboarding\Logs

 

🧰 Prerequisites
Before running the script, ensure:

PowerShell is installed

The following modules are available:

ActiveDirectory

AzureAD

MicrosoftTeamsand MS GRAPH module

You have the necessary admin permissions

⚙️ Configuration Highlights
You’ll need to customize:

$Global:UsersOU – your source OU

$Global:MoveOffboardedOU – destination OU for offboarded users

$Global:EmailDomain, $Global:emailSmtpServer, etc. – for email forwarding and notifications

Logging paths and report directories

🧪 Usage
Run the script in a PowerShell session with elevated privileges. It includes a GUI prompt to select the user and then performs all configured offboarding steps.

 

2) Customizing the O365 hybrid offboarding script for our environment, I’ll need a few details as follows:
🏢 Active Directory Settings
Source OU (where active users are located):
e.g., OU=Employees,DC=yourdomain,DC=com

Destination OU (where offboarded users should be moved):
e.g., OU=OffboardedUsers,DC=yourdomain,DC=com

📧 Email Settings
Primary email domain (used for forwarding and notifications):
e.g., yourcompany.com

SMTP server for sending notifications (optional):
e.g., smtp.yourcompany.com

Email address to notify HR or IT (optional):
e.g., hr@yourcompany.com

🧾 Licensing and Mailbox
Do I want to:

Remove Office 365 licenses?

Convert mailbox to shared?

Set up email forwarding to a manager or shared mailbox?

Removes Office 365 licenses

Converts mailbox to shared

Removes all MFA methods and revokes sessions

Removes phone number

Hides user from the Global Address List

🧑‍💼 Teams and Groups
Should the script:

Remove user from Microsoft Teams?

Remove user from all Azure AD groups?

📁 Logging
Preferred path for logs and reports:
e.g., C:\Scripts\Offboarding\Logs
