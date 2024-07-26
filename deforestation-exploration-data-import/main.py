import pandas as pd
from sqlalchemy import create_engine
import os

BASE_PATH = os.getenv('BASE_PATH')
DB_URL = os.getenv('DB_URL')

def import_csv_to_postgres(csv_file_name):
    """
    Imports a CSV file into a PostgreSQL table.

    :param csv_file_name: Name of the CSV file
    """
    # Define the table name without the .csv extension
    table_name = os.path.splitext(csv_file_name)[0]
    
    # Combine base path and csv file name
    csv_file_path = os.path.join(BASE_PATH, csv_file_name)
    
    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)
    
    # Create an SQLAlchemy engine
    engine = create_engine(DB_URL)
    
    # Import the DataFrame into the PostgreSQL table
    df.to_sql(table_name, engine, if_exists='replace', index=False)
    
    print(f"Data imported successfully into table {table_name}")

# Example usage
import_csv_to_postgres('forest_area.csv')
import_csv_to_postgres('land_area.csv')
import_csv_to_postgres('regions.csv')
