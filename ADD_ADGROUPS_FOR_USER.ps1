<# Adding multiple groups for multiple users. - Dave K. 
To execute the script, I recommend using show_user_group due to distinguished group names for better identification.
The script first reads a txt file with user names and then a txt file with group names.
#>

# Import Active Directory Module
Import-Module ActiveDirectory

# Text file input function
function Select-File($title) {
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $openFileDialog.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
    $openFileDialog.Title = $title

    $result = $openFileDialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileName
    } else {
        Write-Host "$title - File selection was canceled." -ForegroundColor Yellow
        return $null
    }
}

# File with users
$userFilePath = Select-File "Select a text file with user names"
if ($userFilePath -eq $null) {
    Write-Host "No user file selected, script terminated." -ForegroundColor Yellow
    exit
}

# File with groups
$groupFilePath = Select-File "Select a text file with group names"
if ($groupFilePath -eq $null) {
    Write-Host "No group file selected, script terminated." -ForegroundColor Yellow
    exit
}

try {
    $userNames = Get-Content -Path $userFilePath
    $groupNames = Get-Content -Path $groupFilePath

    foreach ($username in $userNames) {
        foreach ($groupname in $groupNames) {
            try {
                # Checking that group exists
                $group = Get-ADGroup -Identity $groupname -ErrorAction Stop
                Write-Host "Group found: $($group.Name)" -ForegroundColor Green
                Write-Host "DistinguishedName: $($group.DistinguishedName)" -ForegroundColor Green

                # Adding user to group
                Add-ADGroupMember -Identity $groupname -Members $username -ErrorAction Stop
                Write-Host "User '$username' added to group '$groupname'" -ForegroundColor Green
            } catch {
                Write-Host "Error for group '$groupname': $_" -ForegroundColor Red 
            }
        }
    }
} catch {
    Write-Host "Error processing files: $_" -ForegroundColor Red
}
