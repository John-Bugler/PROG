import tkinter as tk
from tkinter import messagebox, ttk
import pyodbc
from datetime import datetime


class ActivityMonitor:
    def __init__(self, root):
        self.root = root
        self.root.title("Activity Monitor")
        self.root.geometry("800x600")  # Nastavení výchozí velikosti okna

        self.activity_id = 1
        self.activities = []
        self.current_activity = None
        self.start_time = None

        self.create_widgets()
        self.update_time()

    def create_widgets(self):
        self.root.columnconfigure(0, weight=1)
        self.root.columnconfigure(1, weight=4)  # upraveno pro větší šířku pole
        self.root.rowconfigure(3, weight=1)

        self.time_label = tk.Label(self.root, text="", font=("Helvetica", 16))
        self.time_label.grid(row=0, column=0, columnspan=2, sticky="ew", pady=5)

        self.activity_label = tk.Label(self.root, text="Činnost:")
        self.activity_label.grid(row=1, column=0, sticky="w", padx=5, pady=5)  # Zarovnání vlevo

        self.activity_entry = tk.Entry(self.root)
        self.activity_entry.grid(row=1, column=1, sticky="ew", padx=5, pady=5)  # Zarovnání textového pole vlevo

                
        self.start_stop_button = tk.Button(self.root, text="START", command=self.start_stop_activity, bg='green')
        self.start_stop_button.grid(row=2, column=0, columnspan=2, pady=10)

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
        self.style.configure("Treeview.Heading", font=("Helvetica", 10, "bold"))
        self.style.configure("Treeview", grid=True)  # Zobrazení mřížky

        self.reset_button = tk.Button(self.root, text="RESET", command=self.reset_activities)
        self.reset_button.grid(row=4, column=0, pady=10)

        self.export_button = tk.Button(self.root, text="EXPORT", command=self.export_to_db)
        self.export_button.grid(row=4, column=1, pady=10)



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
        self.start_stop_button.config(text="START", bg='green')

    def reset_activities(self):
        self.activities = []
        for i in self.activity_table.get_children():
            self.activity_table.delete(i)
        self.activity_id = 1

    # Metoda pro export zaznamenaných činností do databáze
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
        
                # Vypočítání trvání v hodinách s přesností na dvě desetinná místa
                duration_hours = round((activity[2] - activity[1]).total_seconds() / 3600, 2)

                # Převedení na řetězec s dvěma desetinnými místy
                duration_str = "{:.2f}".format(duration_hours)



                # Výpis hodnot před vložením do dotazu SQL
                print("ID_activity:", activity[0])
                print("start:", activity[1])
                print("stop:", activity[2])
                print("duration:", duration_str)
                print("activity:", activity[4])


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
