<# GUI application written using Windows.Forms and PresentationFramework - this application reads a txt file with hostnames separated by newlines and checks their availability in the network.
I added a progress bar to improve my skills. After the process is finished, a table is displayed with hosts that respond to ping and those that do not. #>

# Importing modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

# Main program function
function Test-ConnectionHosts {
    param (
        [string]$filePath,
        [System.Windows.Forms.Label]$progressLabel
    )

    if (-Not (Test-Path $filePath)) {
        [System.Windows.Forms.MessageBox]::Show("File does not exist!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $hostnames = Get-Content -Path $filePath
    $totalHosts = $hostnames.Count
    $results = @()

    for ($i = 0; $i -lt $totalHosts; $i++) {
        $hostname = $hostnames[$i]
        $result = Test-Connection -ComputerName $hostname -Count 1 -ErrorAction SilentlyContinue
        if ($result) {
            $results += [PSCustomObject]@{Host=$hostname; Status="Connection OK"; Color="Green"}
        } else {
            $results += [PSCustomObject]@{Host=$hostname; Status="No Connection"; Color="Red"}
        }
        $progress = [math]::Round((($i + 1) / $totalHosts) * 100)
        $progressLabel.Text = "Progress: $progress%"
        $progressLabel.Refresh()
    }

    $results
}

# Load GUI assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Host Connection Test"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

# Open file dialog for selecting hosts file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Text Files (*.txt)|*.txt"
$openFileDialog.Title = "Select a file with hostnames"

# Button to load file and start test
$button = New-Object System.Windows.Forms.Button
$button.Text = "Load File & Test"
$button.Size = New-Object System.Drawing.Size(150, 30)
$button.Location = New-Object System.Drawing.Point(10, 10)

# DataGridView to display results
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size = New-Object System.Drawing.Size(760, 450)
$dataGridView.Location = New-Object System.Drawing.Point(10, 50)
$dataGridView.Font = New-Object System.Drawing.Font("Arial", 12)
$dataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$dataGridView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Progress label
$progressLabel = New-Object System.Windows.Forms.Label
$progressLabel.Size = New-Object System.Drawing.Size(760, 20)
$progressLabel.Location = New-Object System.Drawing.Point(10, 510)
$progressLabel.Text = "Progress: 0%"
$progressLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

# Add controls to form
$form.Controls.Add($button)
$form.Controls.Add($dataGridView)
$form.Controls.Add($progressLabel)

# Button click event
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

# Show the form
[void]$form.ShowDialog()
