# Importing modules
﻿Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

# Main program function
function Test-ConnectionHosts {
    param (
        [string]$filePath,
        [System.Windows.Forms.Label]$progressLabel
    )

    if (-Not (Test-Path $filePath)) {
        [System.Windows.Forms.MessageBox]::Show("Plik nie istnieje!", "Błąd", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $hostnames = Get-Content -Path $filePath
    $totalHosts = $hostnames.Count
    $results = @()

    for ($i = 0; $i -lt $totalHosts; $i++) {
        $hostname = $hostnames[$i]
        $result = Test-Connection -ComputerName $hostname -Count 1 -ErrorAction SilentlyContinue
        if ($result) {
            $results += [PSCustomObject]@{Host=$hostname; Status="Połączenie OK"; Color="Green"}
        } else {
            $results += [PSCustomObject]@{Host=$hostname; Status="Brak połączenia"; Color="Red"}
        }
        $progress = [math]::Round((($i + 1) / $totalHosts) * 100)
        $progressLabel.Text = "Progres: $progress%"
        $progressLabel.Refresh()
    }

    $results
}

# Create GUI
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$form = New-Object System.Windows.Forms.Form
$form.Text = "Test Połączenia z Hostami"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Pliki tekstowe (*.txt)|*.txt"
$openFileDialog.Title = "Wybierz plik z nazwami hostów"

$button = New-Object System.Windows.Forms.Button
$button.Text = "Wczytaj plik i testuj"
$button.Size = New-Object System.Drawing.Size(150, 30)
$button.Location = New-Object System.Drawing.Point(10, 10)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size = New-Object System.Drawing.Size(760, 450)
$dataGridView.Location = New-Object System.Drawing.Point(10, 50)
$dataGridView.Font = New-Object System.Drawing.Font("Arial", 12)
$dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$dataGridView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Size = New-Object System.Drawing.Size(760, 20)
$progressLabel.Location = New-Object System.Drawing.Point(10, 510)
$progressLabel.Text = "Progres: 0%"
$progressLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

$form.Controls.Add($button)
$form.Controls.Add($dataGridView)
$form.Controls.Add($progressLabel)

$button.Add_Click({
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $filePath = $openFileDialog.FileName
        $results = Test-ConnectionHosts -filePath $filePath -progressLabel $progressLabel
        $dataGridView.Rows.Clear()
        $dataGridView.Columns.Clear()
        $dataGridView.Columns.Add("Host", "Host")
        $dataGridView.Columns.Add("Status", "Status")

        foreach ($result in $results) {
            $index = $dataGridView.Rows.Add()
            $row = $dataGridView.Rows[$index]
            $row.Cells[0].Value = $result.Host
            $row.Cells[1].Value = $result.Status
            if ($result.Color -eq "Red") {
                $row.Cells[1].Style.ForeColor = [System.Drawing.Color]::Red
            } else {
                $row.Cells[1].Style.ForeColor = [System.Drawing.Color]::Green
            }
        }
    }
})

[void]$form.ShowDialog()
