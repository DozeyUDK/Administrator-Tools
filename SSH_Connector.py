import tkinter as tk
from tkinter import messagebox
import paramiko
import subprocess
import threading
import os
import time
import pyautogui 


# Function to connect to an SSH server
def connect_and_run(ip, user, password):
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(ip, username=user, password=password)
        return client
    except Exception as e:
        messagebox.showerror("Error", f"Connection failed: {str(e)}")
        return None


# Function to keep the SSH session alive
def keep_alive(client):
    try:
        transport = client.get_transport()
        while transport.is_active():
            transport.send_ignore()  # send an empty packet
            time.sleep(60)
    except Exception as e:
        print(f"Keep-alive error: {str(e)}")


# Function to connect to the server and open a terminal
def autotype_password_in_new_terminal():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    def open_and_autotype():
        try:
            # Connect to the server
            client = connect_and_run(ip, user, password)
            if not client:
                return

            # Start keep-alive in a separate thread
            keep_alive_thread = threading.Thread(target=keep_alive, args=(client,), daemon=True)
            keep_alive_thread.start()

            command = f"ssh {user}@{ip}"
            if is_windows():
                # Open a new CMD terminal
                subprocess.Popen(['cmd', '/K', command], creationflags=subprocess.CREATE_NEW_CONSOLE)
                time.sleep(2)  # Wait for terminal to open
                pyautogui.typewrite(password)  # Auto-type password
                pyautogui.press('enter')  # Press Enter
            else:
                # Linux/MacOS
                subprocess.Popen(['gnome-terminal', '--', 'bash', '-c', f'{command}; sleep 1; echo "{password}"'])
        except Exception as e:
            messagebox.showerror("Error", f"Failed to open terminal: {str(e)}")

    # Run in a thread to avoid blocking GUI
    thread = threading.Thread(target=open_and_autotype)
    thread.start()


# Function to store password in a file
def store_password():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    with open("passwords.txt", "a") as file:
        file.write(f"{ip},{user},{password}\n")


# Function to remember password (overwrite previous)
def remember_password():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    with open("remembered.txt", "w") as file:
        file.write(f"{ip},{user},{password}")


# Function to detect Windows OS
def is_windows():
    return subprocess.os.name == 'nt'


# Function to detect Linux/Mac OS
def is_linux():
    return subprocess.os.name == 'posix'


# Create main application window
root = tk.Tk()
root.title("LAN/VLAN SSH Connector")

# GUI appearance settings
root.configure(bg="#2E2E2E")  # Main window background
root.geometry("500x500")  # Window size
large_font = ('Arial', 12)  # Larger font

# Main frame
center_frame = tk.Frame(root, bg="#2E2E2E")
center_frame.place(relx=0.5, rely=0.5, anchor="center")

# Input fields
label_ip = tk.Label(center_frame, text="Server IP Address:", fg="white", bg="#2E2E2E", font=large_font)
label_ip.pack(pady=5)
entry_ip = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", font=large_font)
entry_ip.pack(pady=5)

label_user = tk.Label(center_frame, text="Username:", fg="white", bg="#2E2E2E", font=large_font)
label_user.pack(pady=5)
entry_user = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", font=large_font)
entry_user.pack(pady=5)

label_password = tk.Label(center_frame, text="Password:", fg="white", bg="#2E2E2E", font=large_font)
label_password.pack(pady=5)
entry_password = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", show="*", font=large_font)
entry_password.pack(pady=5)

# Auto-connect button
btn_connect = tk.Button(
    center_frame,
    text="Connect & Open Terminal (Auto)",
    command=autotype_password_in_new_terminal,
    bg="#555555", fg="white", relief="flat", font=large_font
)
btn_connect.pack(pady=10)

# Store password button
btn_store = tk.Button(center_frame, text="Store Password", command=store_password,
                      bg="#555555", fg="white", relief="flat", font=large_font)
btn_store.pack(pady=10)

# Remember password button
btn_remember = tk.Button(center_frame, text="Remember Credentials", command=remember_password,
                         bg="#555555", fg="white", relief="flat", font=large_font)
btn_remember.pack(pady=10)

# Run the main loop
root.mainloop()
