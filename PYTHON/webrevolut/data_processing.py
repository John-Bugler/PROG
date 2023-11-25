# data_processing.py
def process_data(columns, rows):
    data = [dict(zip(columns, row)) for row in rows]
    return data
