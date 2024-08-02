# Barcode generator :) 
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import barcode
from barcode.writer import ImageWriter

def generate_barcode(data, filename='barcode'):
    barcode_format = barcode.get_barcode_class('code128')
    barcode_obj = barcode_format(data, writer=ImageWriter())
    barcode_obj.save(filename)

def on_generate():
    data = entry.get()
    if data:
        generate_barcode(data, 'barcode_output')
        img = Image.open('barcode_output.png')
        img.thumbnail((400, 400))  # Skalowanie obrazu do rozmiaru okna
        img = ImageTk.PhotoImage(img)
        label.config(image=img)
        label.image = img
    else:
        messagebox.showwarning("Błąd", "Proszę wprowadzić dane!")


# main windows
root = tk.Tk()
root.title("Generator Kodów Kreskowych")

# widgets
entry_label = tk.Label(root, text="Wprowadź tekst lub liczby do zamiany na kod kreskowy:")
entry_label.pack(pady=10)

entry = tk.Entry(root, width=50)
entry.pack(pady=20)

generate_button = tk.Button(root, text="Generuj Kod Kreskowy", command=on_generate)
generate_button.pack(pady=20)

label = tk.Label(root)
label.pack(pady=20)

# main app loop
root.mainloop()


