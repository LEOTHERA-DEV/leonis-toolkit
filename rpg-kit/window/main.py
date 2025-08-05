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
mn_file.add_command(label="New Universe", command=None)
mn_file.add_command(label="Load Universe")
mn_file.add_command(label="Save Universe", command=None)
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
default_theme.configure('Quest.TFrame', background="purple")
default_theme.configure('Skill.TFrame', background='yellow')

# World Content
world_frame = ttk.Frame(main_notebook, style='Char.TFrame')

# Character Content
character_frame = ttk.Frame(main_notebook)
char_main_tree = ttk.Treeview(character_frame, selectmode='browse')
char_main_tree["columns"] = ("ID")
char_main_tree.heading("ID", text="Character ID")
char_main_tree['show'] = 'headings'
char_main_tree.grid(column=0, row=0, rowspan=50)

char_id_label = ttk.Label(character_frame, text="ID")
char_id_label.grid(column=1, row=0, pady=2, sticky='e')
char_id_entry = ttk.Entry(character_frame)
char_id_entry.grid(column=2, row=0, columnspan=2, pady=2, sticky='we')

char_name_label = ttk.Label(character_frame, text="Name")
char_name_label.grid(column=1, row=1, pady=2, sticky='e')
char_name_entry = ttk.Entry(character_frame)
char_name_entry.grid(column=2, row=1, columnspan=2, pady=2, sticky='we')

char_race_label = ttk.Label(character_frame, text="Race")
char_race_label.grid(column=1, row=2, pady=2, sticky='e')
char_race_dropdown = ttk.Combobox(character_frame, values=['Test'])
char_race_dropdown.grid(column=2, row=2, pady=2)
char_race_edit_button = ttk.Button(character_frame, text="Edit", command=None)
char_race_edit_button.grid(column=3, row=2, pady=2)


# Dialogue Content
dialogue_frame = ttk.Frame(main_notebook, style='Dialogue.TFrame')

# Quest Content
quest_frame = ttk.Frame(main_notebook, style='Quest.TFrame')

# Skill Tree Content
skill_frame = ttk.Frame(main_notebook, style='Skill.TFrame')


# Adding all tabs to main Notebook
main_notebook.add(world_frame, text="World")
main_notebook.add(character_frame, text="Characters")
main_notebook.add(dialogue_frame, text="Dialogue")
main_notebook.add(quest_frame, text="Quests")
main_notebook.add(skill_frame, text="Skill Tree")

main_title.pack()
main_notebook.pack(expand=True, fill='both')
main_version.pack(anchor='e')

window_main.config(menu=menu_main)

def run_window():
    window_main.mainloop()