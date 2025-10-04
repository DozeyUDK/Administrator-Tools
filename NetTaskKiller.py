# Remote killing the exe process or another device using tkinter library and WMI - Dave K.

import tkinter as tk
from tkinter import messagebox
import wmi


def terminate_process():
    computer_name = computer_name_entry.get()
    process_name = process_name_entry.get()

    if not computer_name or not process_name:
        messagebox.showerror("Error", "Please fill in all fields.")
        return

    try:
        # Create a WMI object for the target computer
        c = wmi.WMI(computer=computer_name)

        # Retrieve processes with the specified name
        processes = c.Win32_Process(name=process_name)

        if processes:
            for process in processes:
                process.Terminate()
            messagebox.showinfo("Success", f"Successfully terminated process {process_name} on {computer_name}.")
        else:
            messagebox.showinfo(
                "Info",
                f"No running process named {process_name} found on computer {computer_name}."
            )

    except Exception as e:
        messagebox.showerror("Error", f"An error occurred while connecting to the computer: {e}")


# Create the main application window
root = tk.Tk()
root.title("Terminate Process")

# Create labels and entry fields
tk.Label(root, text="Computer Name:").grid(row=0, column=0, padx=10, pady=10, sticky="e")
computer_name_entry = tk.Entry(root, width=50)
computer_name_entry.grid(row=0, column=1, padx=10, pady=10)

tk.Label(root, text="Process Name (.exe):").grid(row=1, column=0, padx=10, pady=10, sticky="e")
process_name_entry = tk.Entry(root, width=50)
process_name_entry.grid(row=1, column=1, padx=10, pady=10)

# Create the terminate button
terminate_button = tk.Button(root, text="Terminate", command=terminate_process)
terminate_button.grid(row=2, columnspan=2, pady=20)

# Run the main application loop
root.mainloop()
