<# Multi-function admin tool. Programik do szybszej pracy w codziennych zadaniach SD.
Skrypt napisany przez: Kmita Dawid - Biuro Wsparcia Użytkownika. Skrypt wymaga psexec i RCV (Endpoint Remote Control Viewer) na hoście gdzie ma być uruchomiony.
Wymagany jest także dostęp do Cisco ISE. #>

Add-Type -AssemblyName System.Windows.Forms

# Definicja funkcji Close-Outlook przed utworzeniem formularza
Function Close-Outlook {
    param (
        [string]$ComputerName
    )

    try {
        $outlookProcess = Get-WmiObject -ComputerName $ComputerName -Class Win32_Process | Where-Object { $_.ProcessName -match "outlook.exe" }
        if ($outlookProcess) {
            $outlookProcess.Terminate()
            return "Zamknięto Outlook"
        } else {
            return "Nie udało się zamknąć Outlooka lub wystąpił problem z połączeniem do hosta."
        }
    }
    catch {
        return "Wystąpił błąd podczas połączenia z komputerem"
    }
}


# Definicja funkcji Open-Explorer przed utworzeniem formularza

Function Open-Explorer {
    param (
        [string]$ComputerName
    )

    $explorerPath = "C:\Windows\explorer.exe"
    $explorerArguments = "\\$ComputerName\c$"
    Start-Process -FilePath $explorerPath -ArgumentList $explorerArguments
}


# Definicja funkcji Restart-Machine przed utworzeniem formularza
Function Restart-Machine {
    param (
        [string]$ComputerName
    )

    try {
        Restart-Computer -ComputerName $ComputerName -Force
        return "Restartowanie komputera..."
    }
    catch {
        return "Wystąpił błąd podczas restartowania komputera"
    }
}

# Funkcja testująca połączenie z komputerem
Function Test-ConnectionToComputer {
    param (
        [string]$ComputerName
    )

    try {
        $ping = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
        if ($ping) {
            return "Połączenie z komputerem $ComputerName jest udane"
        } else {
            return "Brak połączenia z komputerem $ComputerName"
        }
    }
    catch {
        return "Wystąpił błąd podczas testowania połączenia z komputerem"
    }
}
# Funkcja uruchamiająca RCV (WYMAGANY CmRcViewer.exe)

Function Start-RCV {
    param (
        [string]$Path = "C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\i386\CmRcViewer.exe"
    )

    if (Test-Path $Path) {
        Start-Process -FilePath $Path
        Write-Output "CmRcViewer.exe started successfully."
    } else {
        Write-Error "The specified path does not exist: $Path"
    }
}

<# Funkcja uruchamiająca PSEXEC (na razie martwa - w przyszłości zamierzam rozbudować) 

function Start-CmdAndPsexec {
    param (
        [string]$psexecPath,
        [string]$remoteComputer,
        [string]$commandToExecute
    )

    # Uruchom cmd.exe
    Start-Process "cmd.exe" -ArgumentList "/c psexec.exe \\$remoteComputer $commandToExecute" -Wait
} 
#>

# Funkcja uruchamiająca Cisco ISE z przeglądarki (WYMAGANE NADANIE GRUPY W AD DOSTĘPOWEJ)

Function Start-ISE {
Start-Process "https://isepan1001.cn.in.pekao.com.pl/admin/#administration/administration_identitymanagement/administration_identitymanagement_groups"
}


# Funkcja czyszcząca okno konsoli
Function Clear-Console {
    $console.Text = ""
}

# Tworzenie okna formularza
$form = New-Object System.Windows.Forms.Form
$form.Text = "Zarządzanie komputerem"
$form.ClientSize = New-Object System.Drawing.Size(800, 400) # Zmiana szerokości i wysokości okna
$form.StartPosition = "CenterScreen"

# Dodanie okna konsoli
$console = New-Object System.Windows.Forms.TextBox
$console.Location = New-Object System.Drawing.Point(10, 220)
$console.Size = New-Object System.Drawing.Size(780, 100)
$console.Multiline = $true
$console.ScrollBars = "Vertical"
$console.ReadOnly = $true
$form.Controls.Add($console)

# Tworzenie etykiety dla pola wprowadzania
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(180,20) # Zmiana szerokości etykiety
$label.Text = "Wprowadź nazwę komputera:"
$form.Controls.Add($label)

# Tworzenie pola wprowadzania
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(200,20) # Przesunięcie pola wprowadzania
$textbox.Size = New-Object System.Drawing.Size(180,20) # Zmiana szerokości pola wprowadzania
$form.Controls.Add($textbox)

# Tworzenie przycisku "Otwórz eksplorator"
$explorerButton = New-Object System.Windows.Forms.Button
$explorerButton.Location = New-Object System.Drawing.Point(10,70)
$explorerButton.Size = New-Object System.Drawing.Size(150,60) 
$explorerButton.Text = "Otwórz eksplorator"
$explorerButton.Add_Click({
    $computerName = $textbox.Text
    Open-Explorer -ComputerName $computerName
})
$form.Controls.Add($explorerButton)

# Tworzenie przycisku "Zamknij Outlook"
$outlookButton = New-Object System.Windows.Forms.Button
$outlookButton.Location = New-Object System.Drawing.Point(200,70)
$outlookButton.Size = New-Object System.Drawing.Size(150,60) 
$outlookButton.Text = "Zamknij Outlook"
$outlookButton.Add_Click({
    $computerName = $textbox.Text
    $result = Close-Outlook -ComputerName $computerName
    $console.Text += "$result`n"
})
$form.Controls.Add($outlookButton)

# Tworzenie przycisku "Restart komputera"
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Location = New-Object System.Drawing.Point(400,70)
$restartButton.Size = New-Object System.Drawing.Size(150,60) 
$restartButton.Text = "Restart komputera"
$restartButton.Add_Click({
    $computerName = $textbox.Text
    $result = Restart-Machine -ComputerName $computerName
    $console.Text += "$result`n"
})
$form.Controls.Add($restartButton)

# Tworzenie przycisku "Testuj połączenie"
$testConnectionButton = New-Object System.Windows.Forms.Button
$testConnectionButton.Location = New-Object System.Drawing.Point(600,70)
$testConnectionButton.Size = New-Object System.Drawing.Size(150,60) 
$testConnectionButton.Text = "Testuj połączenie"
$testConnectionButton.Add_Click({
    $computerName = $textbox.Text
    $result = Test-ConnectionToComputer -ComputerName $computerName
    $console.Text += "$result`n"
})
$form.Controls.Add($testConnectionButton)


# Tworzenie przycisku "RCV Connector"
$testConnectionButton = New-Object System.Windows.Forms.Button
$testConnectionButton.Location = New-Object System.Drawing.Point(400,140)
$testConnectionButton.Size = New-Object System.Drawing.Size(150,60) 
$testConnectionButton.Text = "Remote Control Viewer"
$testConnectionButton.Add_Click({
    $computerName = $textbox.Text
    $result = Start-RCV
    $console.Text += "$result`n"
})
$form.Controls.Add($testConnectionButton)

# Tworzenie przycisku "Cisco ISE"
$testConnectionButton = New-Object System.Windows.Forms.Button
$testConnectionButton.Location = New-Object System.Drawing.Point(600,140)
$testConnectionButton.Size = New-Object System.Drawing.Size(150,60) 
$testConnectionButton.Text = "Cisco ISE Groups"
$testConnectionButton.Add_Click({
    $computerName = $textbox.Text
    $result = Start-ISE
    $console.Text += "$result`n"
})
$form.Controls.Add($testConnectionButton)

# Tworzenie przycisku "Wyczyść konsolę"
$clearConsoleButton = New-Object System.Windows.Forms.Button
$clearConsoleButton.Location = New-Object System.Drawing.Point(200,140)
$clearConsoleButton.Size = New-Object System.Drawing.Size(150,60) 
$clearConsoleButton.Text = "Wyczyść konsolę"
$clearConsoleButton.Add_Click({
    Clear-Console
})
$form.Controls.Add($clearConsoleButton)

# Tworzenie przycisku "psexec"
$testConnectionButton = New-Object System.Windows.Forms.Button
$testConnectionButton.Location = New-Object System.Drawing.Point(10,140)
$testConnectionButton.Size = New-Object System.Drawing.Size(150,60) 
$testConnectionButton.Text = "PSEXEC"
$testConnectionButton.Add_Click({
    $computerName = $textbox.Text
    Start-Process "cmd.exe" -ArgumentList "/c psexec.exe \\$computerName cmd"
})
$form.Controls.Add($testConnectionButton)

# Uruchomienie formularza
$form.ShowDialog() | Out-Null

