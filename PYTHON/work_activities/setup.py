import sys
from cx_Freeze import setup, Executable

# Seznam balíčků, které chceme zahrnout
packages = ['pyodbc', 'tkinter', 'datetime', 'os', 'pandas']

# Konfigurace setup.py
setup(
    name='work_monitor_v2',
    version='1.0',
    description='Work activities monitor',
    options={
        'build_exe': {
            'packages': packages,
            'include_files': [],  # Zde můžete specifikovat další soubory, které chcete zahrnout (pokud jsou potřeba)
        }
    },
    executables=[
        Executable(
            'work_monitor_v2.py',
            base="Win32GUI",  # Pro konzolovou aplikaci ponechte hodnotu = None / pro winGUI apku pouzijem hodnotu = "Win32GUI"  (jelikoz pouzivam tkinter)
           
        )
    ]
)
