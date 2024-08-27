import tkinter as tk
from tkinter import messagebox, scrolledtext
import subprocess
import os
import requests
import json

# Function to close Outlook
def close_outlook(computer_name):
    try:
        result = subprocess.run(["taskkill", "/S", computer_name, "/IM", "outlook.exe", "/F"], capture_output=True, text=True)
        if "SUCCESS" in result.stdout:
            console_text.insert(tk.END, "Zamknięto Outlook\n")
        else:
            console_text.insert(tk.END, "Nie udało się zamknąć Outlooka lub wystąpił problem z połączeniem do hosta.\n")
    except Exception as e:
        console_text.insert(tk.END, f"Wystąpił błąd podczas połączenia z komputerem: {e}\n")

# Function to open Explorer
def open_explorer(computer_name):
    explorer_path = "C:\\Windows\\explorer.exe"
    explorer_arguments = f"\\\\{computer_name}\\c$"
    subprocess.Popen([explorer_path, explorer_arguments])

# Function to restart machine
def restart_machine(computer_name):
    try:
        subprocess.run(["shutdown", "/m", f"\\\\{computer_name}", "/r", "/f", "/t", "0"])
        console_text.insert(tk.END, "Restartowanie komputera...\n")
    except Exception as e:
        console_text.insert(tk.END, f"Wystąpił błąd podczas restartowania komputera: {e}\n")

# Function to test connection to computer
def test_connection_to_computer(computer_name):
    try:
        response = os.system(f"ping -n 1 {computer_name}")
        if response == 0:
            console_text.insert(tk.END, f"Połączenie z komputerem {computer_name} jest udane\n")
        else:
            console_text.insert(tk.END, f"Brak połączenia z komputerem {computer_name}\n")
    except Exception as e:
        console_text.insert(tk.END, f"Wystąpił błąd podczas testowania połączenia z komputerem: {e}\n")

# Function to start RCV
def start_rcv():
    path = os.path.join("C:\\Program Files (x86)\\Microsoft Endpoint Manager\\AdminConsole\\bin\\i386", "CmRcViewer.exe")
    textbox_value = textbox.get()
    if os.path.exists(path):
        subprocess.Popen([path, textbox_value])
        console_text.insert(tk.END, "CmRcViewer.exe started successfully.\n")
    else:
        console_text.insert(tk.END, f"The specified path does not exist: {path}\n")

# Function to start Cisco ISE
def start_ise():
    try:
        subprocess.Popen(["start", "CISCO ISE URL PASTE HERE"], shell=True)
    except Exception as e:
        console_text.insert(tk.END, f"Failed to start Cisco ISE: {e}\n")

# Function to start Bizon
def start_bizon(computer_name):
    try:
        url = f"EXAMPLE CMDB BASE/?query={computer_name}"
        subprocess.Popen(["start", url], shell=True)
    except Exception as e:
        console_text.insert(tk.END, f"Failed to start BIZON CMDB: {e}\n")
        
def start_RDP(host):
    path = os.path.join("C:\\Windows\\System32", "mstsc.exe")
    host = host.strip()  # Usuń zbędne spacje z końca/początku
    if os.path.isfile(path):
        subprocess.Popen([path, "/v:" + host])
        console_text.insert(tk.END, "RDP started successfully.\n")
    else:
        console_text.insert(tk.END, f"The specified path does not exist: {path}\n")
    

# Function to clear console
def clear_console():
    console_text.delete(1.0, tk.END)

# Main form
app = tk.Tk()
app.title("Zarządzanie komputerem")
app.geometry("800x400")

# Label for computer name input
label = tk.Label(app, text="Wprowadź nazwę komputera:")
label.place(x=10, y=20)

# Textbox for computer name input
textbox = tk.Entry(app, width=30)
textbox.place(x=200, y=20)

# Console text area
console_text = scrolledtext.ScrolledText(app, width=95, height=10, state='normal')
console_text.place(x=10, y=320)

# Buttons
explorer_button = tk.Button(app, text="Otwórz eksplorator", command=lambda: open_explorer(textbox.get()), width=20, height=3)
explorer_button.place(x=10, y=70)

outlook_button = tk.Button(app, text="Zamknij Outlook", command=lambda: close_outlook(textbox.get()), width=20, height=3)
outlook_button.place(x=200, y=70)

restart_button = tk.Button(app, text="Restart komputera", command=lambda: restart_machine(textbox.get()), width=20, height=3)
restart_button.place(x=400, y=70)

test_connection_button = tk.Button(app, text="Testuj połączenie", command=lambda: test_connection_to_computer(textbox.get()), width=20, height=3)
test_connection_button.place(x=600, y=70)

rcv_button = tk.Button(app, text="Remote Control Viewer", command=start_rcv, width=20, height=3)
rcv_button.place(x=400, y=140)

ise_button = tk.Button(app, text="Cisco ISE Groups", command=start_ise, width=20, height=3)
ise_button.place(x=600, y=140)

clear_console_button = tk.Button(app, text="Wyczyść konsolę", command=clear_console, width=20, height=3)
clear_console_button.place(x=200, y=140)

psexec_button = tk.Button(app, text="PSEXEC", command=lambda: subprocess.Popen(["cmd.exe", "/c", f"psexec.exe \\\\{textbox.get()} cmd"], creationflags=subprocess.CREATE_NEW_CONSOLE), width=20, height=3)
psexec_button.place(x=10, y=140)

# Button to start Bizon
bizon_button = tk.Button(app, text="Bizon CMDB", command=lambda: start_bizon(textbox.get()), width=20, height=3)
bizon_button.place(x=600, y=210)

rdp_button = tk.Button(app, text="RDP", command=lambda: start_RDP(textbox.get()), width=20, height=3)
rdp_button.place(x=10, y=210)

app.mainloop()
