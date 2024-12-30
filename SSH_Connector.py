import tkinter as tk
from tkinter import messagebox
import paramiko
import subprocess
import threading
import os
import time
import pyautogui 


# Funkcja do połączenia z serwerem SSH
def connect_and_run(ip, user, password):
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(ip, username=user, password=password)
        return client
    except Exception as e:
        messagebox.showerror("Error", f"Connection failed: {str(e)}")
        return None


# Funkcja do utrzymania sesji SSH przy życiu
def keep_alive(client):
    try:
        transport = client.get_transport()
        while transport.is_active():
            transport.send_ignore()  # wysłanie pustego pakietu
            time.sleep(60)
    except Exception as e:
        print(f"Keep-alive error: {str(e)}")


# Funkcja do połączenia z serwerem i otwarcia terminala
def autotype_password_in_new_terminal():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    def open_and_autotype():
        try:
            # Połączenie z serwerem i uruchomienie terminala
            client = connect_and_run(ip, user, password)
            if not client:
                return

            # Uruchamianie keep-alive w osobnym wątku
            keep_alive_thread = threading.Thread(target=keep_alive, args=(client,), daemon=True)
            keep_alive_thread.start()

            command = f"ssh {user}@{ip}"
            if is_windows():
                # Otwieramy nowy terminal (cmd)
                subprocess.Popen(['cmd', '/K', command], creationflags=subprocess.CREATE_NEW_CONSOLE)
                time.sleep(2)  # Czekamy na otwarcie terminala
                pyautogui.typewrite(password)  # Automatyczne wpisanie hasła
                pyautogui.press('enter')  # Naciśnięcie Enter
            else:
                # Linux/MacOS
                subprocess.Popen(['gnome-terminal', '--', 'bash', '-c', f'{command}; sleep 1; echo "{password}"'])
        except Exception as e:
            messagebox.showerror("Błąd", f"Nie udało się otworzyć terminala: {str(e)}")

    # Uruchamiamy wątek, aby uniknąć blokowania GUI
    thread = threading.Thread(target=open_and_autotype)
    thread.start()


# Funkcja do zapisania danych do pliku
def store_password():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    with open("passwords.txt", "a") as file:
        file.write(f"{ip},{user},{password}\n")


# Funkcja do zapamiętania hasła
def remember_password():
    ip = entry_ip.get()
    user = entry_user.get()
    password = entry_password.get()

    with open("remembered.txt", "w") as file:
        file.write(f"{ip},{user},{password}")


# Funkcja do wykrywania systemu operacyjnego
def is_windows():
    return subprocess.os.name == 'nt'


def is_linux():
    return subprocess.os.name == 'posix'


# Tworzymy główne okno aplikacji
root = tk.Tk()
root.title("LAN/VLAN SSH Connector")

# Ustawienia wyglądu
root.configure(bg="#2E2E2E")  # Tło okna głównego
root.geometry("500x500")  # Rozmiar okna
large_font = ('Arial', 12)  # Większy font

# Główna ramka
center_frame = tk.Frame(root, bg="#2E2E2E")
center_frame.place(relx=0.5, rely=0.5, anchor="center")

# Pola wprowadzania danych
label_ip = tk.Label(center_frame, text="Adres IP serwera:", fg="white", bg="#2E2E2E", font=large_font)
label_ip.pack(pady=5)
entry_ip = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", font=large_font)
entry_ip.pack(pady=5)

label_user = tk.Label(center_frame, text="Użytkownik:", fg="white", bg="#2E2E2E", font=large_font)
label_user.pack(pady=5)
entry_user = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", font=large_font)
entry_user.pack(pady=5)

label_password = tk.Label(center_frame, text="Hasło:", fg="white", bg="#2E2E2E", font=large_font)
label_password.pack(pady=5)
entry_password = tk.Entry(center_frame, width=35, bg="#444444", fg="white", insertbackground="white", show="*", font=large_font)
entry_password.pack(pady=5)

# Przycisk do automatycznego połączenia
btn_connect = tk.Button(center_frame, text="Połącz i otwórz terminal (Auto)", command=autotype_password_in_new_terminal,
                        bg="#555555", fg="white", relief="flat", font=large_font)
btn_connect.pack(pady=10)

# Przycisk do zapisywania haseł
btn_store = tk.Button(center_frame, text="Zapisz hasło", command=store_password,
                      bg="#555555", fg="white", relief="flat", font=large_font)
btn_store.pack(pady=10)

# Przycisk do zapamiętania hasła
btn_remember = tk.Button(center_frame, text="Zapamiętaj dane", command=remember_password,
                         bg="#555555", fg="white", relief="flat", font=large_font)
btn_remember.pack(pady=10)

# Główne loop programu
root.mainloop()
