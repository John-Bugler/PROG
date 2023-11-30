# web_app.py
from flask import Flask, render_template
from db_connector import create_connection, get_data
from data_processing import process_data

webrevolut = Flask(__name__)

@webrevolut.route('/')
def index():
    connection = create_connection()
    columns, rows = get_data(connection)
    data = process_data(columns, rows)
    return render_template('index.html', data=data)

import webbrowser

if __name__ == '__main__':
    webbrowser.open('http://127.0.0.1:5000/')
    webrevolut.run(host='0.0.0.0', port=5000, debug=True)
