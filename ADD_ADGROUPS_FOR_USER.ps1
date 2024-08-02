<#Dodawanie wielu grup dla wielu użytkowników. - Kmita Dawid
Do wykonania skryptu polecam użyć show_user_group z racji distingueshed group names dla lepszego odnajdywania
Skrypt zaczytuje wpierw txt z nazwami użytkowników a potem txt z nazwami grup
Póki co skrypt działa tylko w domenie CN#>

# Import modułu Active Directory, jeśli jeszcze nie został załadowany
Import-Module ActiveDirectory

# Funkcja do wyboru pliku tekstowego z nazwami grup
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

# Wybór pliku z użytkownikami
$userFilePath = Select-File "Select a text file with user names"
if ($userFilePath -eq $null) {
    Write-Host "No user file selected, script terminated." -ForegroundColor Yellow
    exit
}

# Wybór pliku z grupami
$groupFilePath = Select-File "Select a text file with group names"
if ($groupFilePath -eq $null) {
    Write-Host "No group file selected, script terminated." -ForegroundColor Yellow
    exit
}

try {
    # Wczytywanie nazw użytkowników z pliku
    $userNames = Get-Content -Path $userFilePath
    # Wczytywanie nazw grup z pliku
    $groupNames = Get-Content -Path $groupFilePath

    foreach ($username in $userNames) {
        foreach ($groupname in $groupNames) {
            try {
                # Sprawdzanie, czy grupa istnieje
                $group = Get-ADGroup -Identity $groupname -ErrorAction Stop
                Write-Host "Group found: $($group.Name)" -ForegroundColor Green
                Write-Host "DistinguishedName: $($group.DistinguishedName)" -ForegroundColor Green

                # Dodawanie użytkownika do grupy
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
