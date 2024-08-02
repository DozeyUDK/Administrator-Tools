import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import qrcode

def generate_qr(data, filename='qr_code'):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill='black', back_color='white')
    img.save(f"{filename}.png")

def on_generate():
    data = entry.get()
    if data:
        generate_qr(data, 'qr_output')
        img = Image.open('qr_output.png')
        img.thumbnail((400, 400))  # Skalowanie obrazu do rozmiaru okna
        img = ImageTk.PhotoImage(img)
        label.config(image=img)
        label.image = img
    else:
        messagebox.showwarning("Błąd", "Proszę wprowadzić dane!")

# Inicjalizacja głównego okna
root = tk.Tk()
root.title("Generator Kodów QR")

# Tworzenie i ustawianie widżetów
entry_label = tk.Label(root, text="Wprowadź tekst lub liczby do zamiany na kod QR:")
entry_label.pack(pady=10)

entry = tk.Entry(root, width=50)
entry.pack(pady=10)

generate_button = tk.Button(root, text="Generuj Kod QR", command=on_generate)
generate_button.pack(pady=10)

label = tk.Label(root)
label.pack(pady=10)

# Uruchomienie głównej pętli aplikacji
root.mainloop()
