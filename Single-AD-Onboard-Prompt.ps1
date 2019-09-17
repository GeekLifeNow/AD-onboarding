# Set Send-MailMessage information

$SmtpServer = "XX.XX.XX.XX"
$SmtpFrom = "skynet@cyberdyne.net"
$MessageSubject = "New Domain Account Creation"

Import-Module ActiveDirectory

#Information to Console

Write-Host "This script will take the First Name and Last Name of a new user and stage them for work in the Department that is chosen."
Write-Host

#Get user's first/last name

$UserFirstname = Read-host "Enter the first name of the user whom you want to Onboard"
$UserLastname = Read-Host "Enter the last name of the user whom you want to Onboard"

#Get user's department

Write-Host -foregroundcolor Yellow "What Department is this user going to be in?"
Write-host -foregroundcolor Gray "
1>  Manufacturing       2>  Accounting 
3>  Department C        4>  Department D
5>  Department E"
Write-Host

$Department = Read-host "Enter the department #"

#Translates that number into the actual name for ease of use

Switch ($Department){
    1 {$Department = "Manufacturing"}
    2 {$Department = "Accounting"}
    3 {$Department = "Department C"}
    4 {$Department = "Department D"}
    5 {$Department = "Department E"} 
    }

#Set Username (forces all lower case)

$SAMAccountName = ("$UserFirstname" + "." + "$UserLastname").ToLower()

#Set Home Drive Path

$HomeDrivePath = "\\fs01\UserHomeFolders\" + "$SAMAccountName"

# Create the initial user account

try {
    Write-Host
    Write-Host "Creating the inital account: $SAMAccountName..."
    Write-Host
    New-ADUser -Name "$UserFirstname $UserLastname" -GivenName "$UserFirstname" -Surname "$UserLastname" `
        -Path "OU=Users,OU=Site,DC=geeklifenow,DC=com" `
        -UserPrincipalName ("$SAMAccountName" + '@' + "geeklifenow.com") `
        -AccountPassword (ConvertTo-SecureString -AsPlainText "G33kl!feN0w$" -force) `
        -ChangePasswordAtLogon $true `
        -SamAccountName "$SAMAccountName" `
        -Enabled $true `
        -DisplayName "$UserFirstname $UserLastname" `
        -Description "$Department" `
        -Office "GeekLifeNow HQ" `
        -ErrorAction Stop
        Write-Host "SUCCESS: The user account: $SAMAccountName has been created!" -ForegroundColor Green
        Write-Host
    }
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "WARNING: Error in creating the account: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
    Write-Host
    Read-Host -Prompt "Press Enter to exit..."
    break
}

<#
    Adds User to the specified AD groups corresponding to pre-filled .txt files with group names
#>

switch($Department){

    "Manufacturing" {
                
        # Add the groups for the user (off of a template text file)
            
        $Groups = Get-content "C:\Scripts\DeptGroups\Manufacturing.txt"
        Write-Host "Adding the account to the following AD security groups: $Groups"
        Write-Host
        try { 
            foreach ($Group in $Groups){
            Add-ADGroupMember -Identity "$Group" -Members "$SAMAccountName"
            }
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
            }    
        catch {    
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in adding to AD security groups: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
            
        # Moves the user account from the generic location to where it needs to live
            
        Write-Host "Moving AD user object to its proper OU..."
        Write-Host    
        try {
            Get-ADUser -Identity $SAMAccountName | Move-ADObject -TargetPath "OU=Manufacturing,OU=Users,OU=Site,DC=geeklifenow,DC=com"
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in moving to OU: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
            
        # Set the TO: address list and construct the body of the email notification.

        $SmtpTo = "geek@geeklifenow.com"
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "Dear <b><font color=red>Manufacturing Team,</b></font><br>"
        $body += "<br>"
        $body += "This is an notification of a newly created domain account.<br>"
        $body += "<br>"
        $body += "<b>$SAMAccountName</b> has been created and will be migrated soon.<br>"
        $body += "<br>"
        $body += "The password for this account is <b>G33kl!feN0w$</b> and the user will be prompted to change it upon 1st login.<br>"
        $body += "<br>"
        $body += "- GeekLifeNow IT Department"
            
        # Send the email notification of created account
            
        try {
            Send-MailMessage -To $SmtpTo -From $SmtpFrom -Subject $MessageSubject -SmtpServer $SmtpServer -Body $body -BodyAsHtml
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in sending email notification: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
            
        #Final success message to the console
            
        Write-Host "Account created and staged successfully!"
        Write-Host
        Read-Host -Prompt "Press Enter to exit"
    
    }

    "Accounting" {

        # Add the groups for the user (off of a template text file)
            
        $Groups = Get-content "C:\Scripts\DeptGroups\Accounting.txt"
        Write-Host "Adding the account to the following AD security groups: $Groups"
        Write-Host
        try { 
            foreach ($Group in $Groups){
            Add-ADGroupMember -Identity "$Group" -Members "$SAMAccountName"
            }
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }    
        catch {    
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in adding to AD security groups: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Moves the user account from the generic location to where it needs to live
        
        Write-Host "Moving AD user object to its proper OU..."
        Write-Host    
        try {
            Get-ADUser -Identity $SAMAccountName | Move-ADObject -TargetPath "OU=Accounting,OU=Users,OU=Site,DC=geeklifenow,DC=com"
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in moving to OU: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Set the TO: address list and construct the body of the email notification.

        $SmtpTo = "geek@geeklifenow.com"
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "Dear <b><font color=red>Accounting Team,</b></font><br>"
        $body += "<br>"
        $body += "This is an notification of a newly created domain account.<br>"
        $body += "<br>"
        $body += "<b>$SAMAccountName</b> has been created and will be migrated soon.<br>"
        $body += "<br>"
        $body += "The password for this account is <b>G33kl!feN0w$</b> and the user will be prompted to change it upon 1st login.<br>"
        $body += "<br>"
        $body += "- GeekLifeNow IT Department"
        
        # Send the email notification of created account
        
        try {
            Send-MailMessage -To $SmtpTo -From $SmtpFrom -Subject $MessageSubject -SmtpServer $SmtpServer -Body $body -BodyAsHtml
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in sending email notification: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        #Final success message to the console
        
        Write-Host "Account created and staged successfully!"
        Write-Host
        Read-Host -Prompt "Press Enter to exit"    
     }
     
     "Department C" {

        # Add the groups for the user (off of a template text file)
            
        $Groups = Get-content "C:\Scripts\DeptGroups\DepartmentC.txt"
        Write-Host "Adding the account to the following AD security groups: $Groups"
        Write-Host
        try { 
            foreach ($Group in $Groups){
            Add-ADGroupMember -Identity "$Group" -Members "$SAMAccountName"
            }
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }    
        catch {    
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in adding to AD security groups: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Moves the user account from the generic location to where it needs to live
            
        Write-Host "Moving AD user object to its proper OU..."
        Write-Host    
        try {
            Get-ADUser -Identity $SAMAccountName | Move-ADObject -TargetPath "OU=Department C,OU=Users,OU=Site,DC=geeklifenow,DC=com"
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in moving to OU: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
     
        # Set the home drive letter on the account
            
        Write-Host "Setting the home drive letter to G: and and adding the path..."
        Write-Host
        try {
            Set-ADUser -Identity $SAMAccountName -HomeDrive "G:" -HomeDirectory $HomeDrivePath
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in setting the home drive letter/path: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
              
        # Create home directory folder & set permissions

        Write-Host "Creating the home folder and setting permissions..."
        Write-Host
        try {
            $HomeShare = New-Item -Path $HomeDrivePath -ItemType Directory -Force
            $ACL = Get-Acl $HomeShare
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("GEEKLIFE\$SAMAccountName", "Modify", "ContainerInherit, ObjectInherit", "InheritOnly", "Allow")
            $ACL.AddAccessRule($AccessRule)
            $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule ("GEEKLIFE\$SAMAccountName", "Modify", "None", "InheritOnly", "Allow")
            $ACL.AddAccessRule($AccessRule)
            Set-Acl -Path $HomeShare -AclObject $ACL
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in creating the home drive folder: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Set the TO: address list and construct the body of the email notification.

        $SmtpTo = "geek@geeklifenow.com"
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "Dear <b><font color=red>Department C Team,</b></font><br>"
        $body += "<br>"
        $body += "This is an notification of a newly created domain account.<br>"
        $body += "<br>"
        $body += "<b>$SAMAccountName</b> has been created and will be migrated soon.<br>"
        $body += "<br>"
        $body += "The password for this account is <b>G33kl!feN0w$</b> and the user will be prompted to change it upon 1st login.<br>"
        $body += "<br>"
        $body += "- GeekLifeNow IT Department"
        
        # Send the email notification of created account
        
        try {
            Send-MailMessage -To $SmtpTo -From $SmtpFrom -Subject $MessageSubject -SmtpServer $SmtpServer -Body $body -BodyAsHtml
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in sending email notification: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        #Final success message to the console
            
        Write-Host "Account created and staged successfully!"
        Write-Host
        Read-Host -Prompt "Press Enter to exit"     
     }
         
     "Department D" {

        # Add the groups for the user (off of a template text file)
            
        $Groups = Get-content "C:\Scripts\DeptGroups\DepartmentD.txt"
        Write-Host "Adding the account to the following AD security groups: $Groups"
        Write-Host
        try { 
            foreach ($Group in $Groups){
            Add-ADGroupMember -Identity "$Group" -Members "$SAMAccountName"
            }
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }    
        catch {    
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in adding to AD security groups: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Moves the user account from the generic location to where it needs to live
        
        Write-Host "Moving AD user object to its proper OU..."
        Write-Host    
        try {
            Get-ADUser -Identity $SAMAccountName | Move-ADObject -TargetPath "OU=Department D,OU=Users,OU=Site,DC=geeklifenow,DC=com"
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in moving to OU: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Set the TO: address list and construct the body of the email notification.

        $SmtpTo = "geek@geeklifenow.com"
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "Dear <b><font color=red>Department D Team,</b></font><br>"
        $body += "<br>"
        $body += "This is an notification of a newly created domain account.<br>"
        $body += "<br>"
        $body += "<b>$SAMAccountName</b> has been created and will be migrated soon.<br>"
        $body += "<br>"
        $body += "The password for this account is <b>G33kl!feN0w$</b> and the user will be prompted to change it upon 1st login.<br>"
        $body += "<br>"
        $body += "- GeekLifeNow IT Department"
        
        # Send the email notification of created account
        
        try {
            Send-MailMessage -To $SmtpTo -From $SmtpFrom -Subject $MessageSubject -SmtpServer $SmtpServer -Body $body -BodyAsHtml
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in sending email notification: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        #Final success message to the console
        
        Write-Host "Account created and staged successfully!"
        Write-Host
        Read-Host -Prompt "Press Enter to exit"    
     }
    
      "Department E" {

        # Add the groups for the user (off of a template text file)
            
        $Groups = Get-content "C:\Scripts\DeptGroups\DepartmentE.txt"
        Write-Host "Adding the account to the following AD security groups: $Groups"
        Write-Host
        try { 
            foreach ($Group in $Groups){
            Add-ADGroupMember -Identity "$Group" -Members "$SAMAccountName"
            }
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }    
        catch {    
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in adding to AD security groups: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Moves the user account from the generic location to where it needs to live
        
        Write-Host "Moving AD user object to its proper OU..."
        Write-Host    
        try {
            Get-ADUser -Identity $SAMAccountName | Move-ADObject -TargetPath "OU=Department E,OU=Users,OU=Site,DC=geeklifenow,DC=com"
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in moving to OU: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        # Set the TO: address list and construct the body of the email notification.

        $SmtpTo = "geek@geeklifenow.com"
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "Dear <b><font color=red>Department E Team,</b></font><br>"
        $body += "<br>"
        $body += "This is an notification of a newly created domain account.<br>"
        $body += "<br>"
        $body += "<b>$SAMAccountName</b> has been created and will be migrated soon.<br>"
        $body += "<br>"
        $body += "The password for this account is <b>G33kl!feN0w$</b> and the user will be prompted to change it upon 1st login.<br>"
        $body += "<br>"
        $body += "- GeekLifeNow IT Department"
        
        # Send the email notification of created account
        
        try {
            Send-MailMessage -To $SmtpTo -From $SmtpFrom -Subject $MessageSubject -SmtpServer $SmtpServer -Body $body -BodyAsHtml
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "WARNING: Error in sending email notification: $ErrorMessage" -ForegroundColor Red -BackgroundColor Black
            Write-Host
            Read-Host -Prompt "Press Enter to exit..."
            break
        }
        
        #Final success message to the console
        
        Write-Host "Account created and staged successfully!"
        Write-Host
        Read-Host -Prompt "Press Enter to exit"
    }
}

