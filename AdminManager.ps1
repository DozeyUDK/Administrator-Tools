<# Multi-function admin tool. A program for faster work in daily SD tasks.
Script written by: Dawid Kmita - User Support Office. The script requires psexec and RCV (Endpoint Remote Control Viewer) on the host where it is to be run.
Access to Cisco ISE is also required. Dave K. #>

Add-Type -AssemblyName System.Windows.Forms

# definition of closing outlook before creating formula
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


# definition open explorer before creating formula

Function Open-Explorer {
    param (
        [string]$ComputerName
    )

    $explorerPath = "C:\Windows\explorer.exe"
    $explorerArguments = "\\$ComputerName\c$"
    Start-Process -FilePath $explorerPath -ArgumentList $explorerArguments
}


# definition restart machine before creating formula
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

# test connection before executing 
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
# function that launch RCV (SCCM Remote Control Viewer - CmRcViewer.exe REQUIRED)

Function Start-RCV {
    param (
        [string]$Path = "PATH_TO_SCCM_RCV"
    )

    if (Test-Path $Path) {
        Start-Process -FilePath $Path
        Write-Output "CmRcViewer.exe started successfully."
    } else {
        Write-Error "The specified path does not exist: $Path"
    }
}


Function Start-ISE {
Start-Process "URL_PATH_TO_CISCO_ISE"
}


# clear the console windows
Function Clear-Console {
    $console.Text = ""
}

# creating the window formula
$form = New-Object System.Windows.Forms.Form
$form.Text = "Zarządzanie komputerem"
$form.ClientSize = New-Object System.Drawing.Size(800, 400) # Zmiana szerokości i wysokości okna
$form.StartPosition = "CenterScreen"

# add console window
$console = New-Object System.Windows.Forms.TextBox
$console.Location = New-Object System.Drawing.Point(10, 220)
$console.Size = New-Object System.Drawing.Size(780, 100)
$console.Multiline = $true
$console.ScrollBars = "Vertical"
$console.ReadOnly = $true
$form.Controls.Add($console)

# label conture
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(180,20) 
$label.Text = "Wprowadź nazwę komputera:"
$form.Controls.Add($label)

# label input
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(200,20) 
$textbox.Size = New-Object System.Drawing.Size(180,20) 
$form.Controls.Add($textbox)

# open explorer button
$explorerButton = New-Object System.Windows.Forms.Button
$explorerButton.Location = New-Object System.Drawing.Point(10,70)
$explorerButton.Size = New-Object System.Drawing.Size(150,60) 
$explorerButton.Text = "Otwórz eksplorator"
$explorerButton.Add_Click({
    $computerName = $textbox.Text
    Open-Explorer -ComputerName $computerName
})
$form.Controls.Add($explorerButton)

# close outlook button
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

# reset computer button
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

# test connection button
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


# rcv connectior button
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

# cisco ise button
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

# clear console button
$clearConsoleButton = New-Object System.Windows.Forms.Button
$clearConsoleButton.Location = New-Object System.Drawing.Point(200,140)
$clearConsoleButton.Size = New-Object System.Drawing.Size(150,60) 
$clearConsoleButton.Text = "Wyczyść konsolę"
$clearConsoleButton.Add_Click({
    Clear-Console
})
$form.Controls.Add($clearConsoleButton)

# PSEXEC button
$testConnectionButton = New-Object System.Windows.Forms.Button
$testConnectionButton.Location = New-Object System.Drawing.Point(10,140)
$testConnectionButton.Size = New-Object System.Drawing.Size(150,60) 
$testConnectionButton.Text = "PSEXEC"
$testConnectionButton.Add_Click({
    $computerName = $textbox.Text
    Start-Process "cmd.exe" -ArgumentList "/c psexec.exe \\$computerName cmd"
})
$form.Controls.Add($testConnectionButton)

# execute
$form.ShowDialog() | Out-Null

