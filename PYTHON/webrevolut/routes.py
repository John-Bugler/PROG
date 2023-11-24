from flask import render_template
from webrevolut import app
from database import get_data

@app.route('/')
def index():
    data = get_data()
    return render_template('index.html', data=data)
