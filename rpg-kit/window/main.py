import tkinter as tk
from tkinter import ttk, messagebox

window_main = tk.Tk()

window_main.title("RPG KIT")
window_main.geometry("600x480")
window_main.resizable(False, False)

def quit_application():
    quit_confirm = messagebox.askyesno("Exit Application", "Are you sure?")
    if quit_confirm:
        exit(0)

# Menubar (mn)
menu_main = tk.Menu(window_main)

mn_file = tk.Menu(menu_main, tearoff=0)
menu_main.add_cascade(label="File", menu = mn_file)
mn_file.add_command(label="New File", command=None)
mn_file.add_command(label="Save File", command=None)
mn_file.add_separator()
mn_file.add_command(label="Import", command=None)
mn_file.add_command(label="Export", command=None)
mn_file.add_separator()
mn_file.add_command(label="Exit", command=quit_application)

main_title = tk.Label(window_main, text="LEONIS RPG KIT")
main_notebook = ttk.Notebook(window_main)
main_version = ttk.Label(window_main, text="MVP Build")

# Window themes
default_theme = ttk.Style()
default_theme.configure('Char.TFrame', background='red')
default_theme.configure('World.TFrame', background='green')
default_theme.configure('Dialogue.TFrame', background='blue')

# Character Content
world_frame = ttk.Frame(main_notebook, style='Char.TFrame')
character_frame = ttk.Frame(main_notebook, style='World.TFrame')
dialogue_frame = ttk.Frame(main_notebook, style='Dialogue.TFrame')


# Adding all tabs to main Notebook
main_notebook.add(world_frame, text="World")
main_notebook.add(character_frame, text="Characters")
main_notebook.add(dialogue_frame, text="Dialogue")

main_title.pack()
main_notebook.pack(anchor='w', expand=True, fill='both')
main_version.pack(anchor='e')

window_main.config(menu=menu_main)

def run_window():
    window_main.mainloop()