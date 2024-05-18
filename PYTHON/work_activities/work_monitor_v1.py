import tkinter as tk
from tkinter import messagebox, ttk
import pyodbc
from datetime import datetime


class ActivityMonitor:
    def __init__(self, root):
        self.root = root
        self.root.title("Activity Monitor")
        self.root.geometry("800x600")  

        self.activity_id = 1
        self.activities = []
        self.current_activity = None
        self.start_time = None

        self.create_widgets()
        self.update_time()

    def create_widgets(self):
        self.root.columnconfigure(0, weight=1)
        self.root.columnconfigure(1, weight=4)  
        self.root.rowconfigure(0, weight=0)
        self.root.rowconfigure(1, weight=0)
        self.root.rowconfigure(2, weight=0)
        self.root.rowconfigure(3, weight=1)

        self.time_label = tk.Label(self.root, text="", font=("Calibri", 20, "bold"))
        self.time_label.grid(row=0, column=0, columnspan=2, sticky="ew", pady=5)

        self.activity_label = tk.Label(self.root, text="Činnost:")
        self.activity_label.grid(row=1, column=0, sticky="w", padx=5, pady=5)  

        self.activity_entry = tk.Entry(self.root)
        self.activity_entry.grid(row=1, column=1, sticky="ew", padx=5, pady=5)  

        self.start_stop_button = tk.Button(self.root, text="START", font=("Calibri", 20, "bold"), command=self.start_stop_activity, bg='light green')
        self.start_stop_button.grid(row=2, column=1, columnspan=2, pady=10, sticky="ew")

        self.duration_label = tk.Label(self.root, text="Průběh trvání: 00:00:00", font=("Calibri", 12, "bold"))
        self.duration_label.grid(row=2, column=0, columnspan=1)

        self.activity_table = ttk.Treeview(self.root, columns=("ID", "Start", "Konec", "Trvání", "Činnost"), show="headings")
        self.activity_table.heading("ID", text="ID")
        self.activity_table.heading("Start", text="Start")
        self.activity_table.heading("Konec", text="Konec")
        self.activity_table.heading("Trvání", text="Trvání")
        self.activity_table.heading("Činnost", text="Činnost")
        self.activity_table.column("ID", width=30, anchor="center")
        self.activity_table.column("Start", width=150, anchor="center")
        self.activity_table.column("Konec", width=150, anchor="center")
        self.activity_table.column("Trvání", width=80, anchor="center")
        self.activity_table.column("Činnost", width=300, anchor="w")  # Zarovnání vlevo
        self.activity_table.grid(row=3, column=0, columnspan=2, sticky="nsew", padx=5, pady=5)

        self.style = ttk.Style()
        self.style.configure("Treeview.Heading", font=("Calibri", 10, "bold"))
        self.style.configure("Treeview", grid=True)  

        self.reset_button = tk.Button(self.root, text="RESET", command=self.reset_activities)
        self.reset_button.grid(row=5, column=0, pady=10)

        self.export_button = tk.Button(self.root, text="EXPORT", command=self.export_to_db)
        self.export_button.grid(row=5, column=1, pady=10)

    def update_time(self):
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self.time_label.config(text=now)
        self.root.after(1000, self.update_time)

    def start_stop_activity(self):
        if self.current_activity is None:
            self.start_activity()
        else:
            self.stop_activity()

    def start_activity(self):
        activity_name = self.activity_entry.get()
        if not activity_name:
            messagebox.showwarning("Varování", "Zadejte název činnosti.")
            return
        if len(activity_name) > 200:
            messagebox.showwarning("Varování", "Název činnosti nesmí přesáhnout 200 znaků.")
            return

        self.current_activity = activity_name
        self.start_time = datetime.now()
        self.start_stop_button.config(text="STOP", bg='red')
        self.update_duration()  

    def stop_activity(self):
        end_time = datetime.now()
        duration = (end_time - self.start_time).total_seconds() / 3600
        formatted_start = self.start_time.strftime("%H:%M:%S")
        formatted_end = end_time.strftime("%H:%M:%S")
        self.activities.append((self.activity_id, self.start_time, end_time, duration, self.current_activity))
        self.activity_table.insert("", "end", values=(self.activity_id, formatted_start, formatted_end, f"{duration:.2f}", self.current_activity))

        self.activity_id += 1
        self.current_activity = None
        self.start_time = None
        self.start_stop_button.config(text="START", bg='light green')

    def update_duration(self):
        if self.current_activity is not None:
            current_time = datetime.now()
            duration = (current_time - self.start_time).total_seconds()
            hours, remainder = divmod(duration, 3600)
            minutes, seconds = divmod(remainder, 60)
            duration_str = "{:02}:{:02}:{:02}".format(int(hours), int(minutes), int(seconds))
            self.duration_label.config(text="Průběh trvání: " + duration_str)
            self.root.after(1000, self.update_duration)

    def reset_activities(self):
        self.activities = []
        for i in self.activity_table.get_children():
            self.activity_table.delete(i)
        self.activity_id = 1

    def export_to_db(self):
        if not self.activities:
            messagebox.showinfo("Info", "Nejsou žádné záznamy k exportu.")
            return

        try:
            server = 'localhost'
            database = 'reports'
            connection = pyodbc.connect(f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes')
            cursor = connection.cursor()

            for activity in self.activities:
                duration_hours = round((activity[2] - activity[1]).total_seconds() / 3600, 2)
                duration_str = "{:.2f}".format(duration_hours)
                cursor.execute("""
                    INSERT INTO [reports].[dbo].[Work_Activities] (ID_activity, start, stop, duration, activity)
                    VALUES (?, ?, ?, ?, ?)
                """, (activity[0], activity[1], activity[2], duration_str, activity[4]))

            connection.commit()
            connection.close()

            messagebox.showinfo("Info", "Data úspěšně exportována do databáze.")
            self.reset_activities()
        except Exception as e:
            messagebox.showerror("Chyba", f"Chyba při exportu dat do databáze: {str(e)}")


if __name__ == "__main__":
    root = tk.Tk()
    app = ActivityMonitor(root)
    root.mainloop()
