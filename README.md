# O365-on-Prem-AD


🔒 **User Offboarding Automation Script**
This PowerShell script automates the offboarding process for users in a hybrid Active Directory and Microsoft 365 environment. It ensures a secure, consistent, and logged deprovisioning of user accounts, licenses, and access.

📂 **Features**
Connects to Microsoft Graph, Exchange Online, and Active Directory
Prompts for user input (UPN and SAM account name)
Logs all actions to a timestamped log file
Performs the following offboarding steps:
Generates and sets a secure random password
Disables the on-premises AD account
Moves the user to an "OffBoarded Users" OU
Hides the user from the Global Address List (GAL)
Removes all Microsoft 365 licenses
Converts the mailbox to a shared mailbox
Removes all MFA methods
Revokes all Azure AD sessions
Clears phone numbers
Removes the user from all Azure AD groups
Removes enterprise application role assignments
Sends a notification email to IT


🛠️ **Requirements**
PowerShell 7.0+
Modules:
Microsoft.Graph.Users
Microsoft.Graph.Groups
Microsoft.Graph.Identity.SignIns
Microsoft.Graph.Authentication
ActiveDirectory
ExchangeOnlineManagement
Admin credentials with appropriate permissions

📥 **Input**
The script prompts for:

User Principal Name (UPN) — e.g., jdoe@someone.ca
SAM Account Name — e.g., jdoe

📤 **Output**
A detailed log file saved in C:\Scripts\Offboarding\Logs
Email notification sent to ITRequests@someone.ca

🚀 **Usage**

Follow the prompts to enter the UPN and SAM account name of the user to offboard.

📧 **Notification**
At the end of the process, an email is sent to the IT department with a summary and a link to the log file.

⚠️ **Disclaimer**
Ensure you test this script in a development environment before using it in production. Modify paths, email addresses, and OU names as needed for your organization.
