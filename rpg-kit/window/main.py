import tkinter as tk
from tkinter import ttk, messagebox

window_main = tk.Tk()

window_main.title("RPG KIT")
window_main.geometry("480x580")
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
char_main_tree.heading("ID", text="Characters")
char_main_tree['show'] = 'headings'
char_main_tree.grid(column=0, row=0, rowspan=50)

char_main_add_button = ttk.Button(character_frame, text="Add Character")
char_main_add_button.grid(column=0, row=51, sticky='we')

char_detail_frame = ttk.Labelframe(character_frame, text="Information")
char_detail_frame.grid(column=1, row=0, pady=2, columnspan=4)

char_id_label = ttk.Label(char_detail_frame, text="ID")
char_id_label.grid(column=1, row=0, pady=2, sticky='e')
char_id_entry = ttk.Entry(char_detail_frame)
char_id_entry.grid(column=2, row=0, columnspan=3, pady=2, sticky='we')

char_name_label = ttk.Label(char_detail_frame, text="Name")
char_name_label.grid(column=1, row=1, pady=2, sticky='e')
char_name_entry = ttk.Entry(char_detail_frame)
char_name_entry.grid(column=2, row=1, columnspan=3, pady=2, sticky='we')

char_race_label = ttk.Label(char_detail_frame, text="Race")
char_race_label.grid(column=1, row=2, pady=2, sticky='e')
char_race_entry = ttk.Entry(char_detail_frame)
char_race_entry.grid(column=2, row=2, columnspan=3, pady=2, sticky='we')

char_hp_label = ttk.Label(char_detail_frame, text="Hit Points")
char_hp_label.grid(column=1, row=3, pady=2, sticky='e')
char_hp_entry = ttk.Scale(char_detail_frame, orient='horizontal')
char_hp_entry.grid(column=2, row=3, columnspan=3, pady=2, sticky='we')

char_stats_frame = ttk.Labelframe(character_frame, text="Stats")
char_stats_frame.grid(column=1, row=4, columnspan=4, pady=2)

char_stats_atk_label = ttk.Label(char_stats_frame, text="Strength")
char_stats_atk_label.grid(column=1, row=5, sticky='e')
char_stats_atk_value = ttk.Spinbox(char_stats_frame, width=5)
char_stats_atk_value.grid(column=2, row=5)

char_stats_dex_label = ttk.Label(char_stats_frame, text="Dexterity")
char_stats_dex_label.grid(column=3, row=5, sticky='e')
char_stats_dex_value = ttk.Spinbox(char_stats_frame, width=5)
char_stats_dex_value.grid(column=4, row=5)

char_stats_int_label = ttk.Label(char_stats_frame, text="Intelligence")
char_stats_int_label.grid(column=1, row=6, sticky='e')
char_stats_int_value = ttk.Spinbox(char_stats_frame, width=5)
char_stats_int_value.grid(column=2, row=6)

char_stats_wis_label = ttk.Label(char_stats_frame, text="Wisdom")
char_stats_wis_label.grid(column=3, row=6, sticky='e')
char_stats_wis_value = ttk.Spinbox(char_stats_frame, width=5)
char_stats_wis_value.grid(column=4, row=6)


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