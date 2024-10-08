# Generator qr sieci wifi

import tkinter as tk
from tkinter import messagebox
import qrcode
from PIL import Image, ImageTk, ImageOps

# Funkcja generująca kod QR i wyświetlająca go w oknie aplikacji
def generate_qr_code():
    ssid = ssid_entry.get()
    password = password_entry.get()
    encryption_type = encryption_var.get()

    if not ssid or not encryption_type:
        messagebox.showwarning("Błąd", "Proszę wprowadzić SSID i wybrać typ szyfrowania.")
        return

    wifi_config = f"WIFI:T:{encryption_type};S:{ssid};P:{password};;"

    # Generowanie kodu QR
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(wifi_config)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")

    # Zapisanie tymczasowego obrazu
    img.save("wifi_qr_code_temp.png")

    # Wczytanie i wyświetlenie obrazu w tkinter
    qr_img = Image.open("wifi_qr_code_temp.png")
    qr_img = qr_img.resize((200, 200), Image.Resampling.LANCZOS)  # Skalowanie obrazu
    qr_photo = ImageTk.PhotoImage(qr_img)

    qr_label.config(image=qr_photo)
    qr_label.image = qr_photo  # Przechowywanie referencji do obrazu

# Konfiguracja okna głównego
root = tk.Tk()
root.title("Generator QR dla Wi-Fi")

# Ramka do wprowadzania danych
input_frame = tk.Frame(root)
input_frame.pack(pady=10)

# Pole do wprowadzenia SSID
tk.Label(input_frame, text="SSID:").grid(row=0, column=0, padx=5, pady=5)
ssid_entry = tk.Entry(input_frame, width=30)
ssid_entry.grid(row=0, column=1, padx=5, pady=5)

# Pole do wprowadzenia hasła
tk.Label(input_frame, text="Hasło:").grid(row=1, column=0, padx=5, pady=5)
password_entry = tk.Entry(input_frame, show='*', width=30)
password_entry.grid(row=1, column=1, padx=5, pady=5)

# Opcje wyboru typu szyfrowania
tk.Label(input_frame, text="Szyfrowanie:").grid(row=2, column=0, padx=5, pady=5)
encryption_var = tk.StringVar(value="WPA")
tk.OptionMenu(input_frame, encryption_var, "WPA", "WEP", "").grid(row=2, column=1, padx=5, pady=5)

# Przycisk generowania kodu QR
generate_button = tk.Button(root, text="Generuj Kod QR", command=generate_qr_code)
generate_button.pack(pady=10)

# Etykieta do wyświetlenia kodu QR
qr_label = tk.Label(root)
qr_label.pack(pady=10)

# Uruchomienie aplikacji
root.mainloop()
