import tkinter as tk
from tkinter import messagebox
import wmi


def terminate_process():
    computer_name = computer_name_entry.get()
    process_name = process_name_entry.get()

    if not computer_name or not process_name:
        messagebox.showerror("Błąd", "Proszę wypełnić wszystkie pola.")
        return

    try:
        # Tworzenie obiektu WMI
        c = wmi.WMI(computer=computer_name)

        # Pobranie procesów
        processes = c.Win32_Process(name=process_name)

        if processes:
            for process in processes:
                process.Terminate()
            messagebox.showinfo("Sukces", f"Prawidłowe zamknięcie procesu {process_name} na {computer_name}.")
        else:
            messagebox.showinfo("Informacja",
                                f"Brak uruchomionego procesu {process_name} na komputerze {computer_name}.")

    except Exception as e:
        messagebox.showerror("Błąd", f"Wystąpił błąd podczas połączenia z komputerem: {e}")


# Tworzenie głównego okna aplikacji
root = tk.Tk()
root.title("Zamknij Proces")

# Tworzenie etykiet i pól tekstowych
tk.Label(root, text="Nazwa Komputera:").grid(row=0, column=0, padx=10, pady=10, sticky="e")
computer_name_entry = tk.Entry(root, width=50)
computer_name_entry.grid(row=0, column=1, padx=10, pady=10)

tk.Label(root, text="Nazwa Procesu (.exe):").grid(row=1, column=0, padx=10, pady=10, sticky="e")
process_name_entry = tk.Entry(root, width=50)
process_name_entry.grid(row=1, column=1, padx=10, pady=10)

# Tworzenie przycisku
terminate_button = tk.Button(root, text="Zamknij", command=terminate_process)
terminate_button.grid(row=2, columnspan=2, pady=20)

# Uruchomienie pętli głównej aplikacji
root.mainloop()
