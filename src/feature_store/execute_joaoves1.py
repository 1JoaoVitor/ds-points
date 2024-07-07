# %% 

import sqlalchemy
import pandas as pd
import datetime
import argparse
from tqdm import tqdm
from sqlalchemy import exc 

def import_query(path): 

    with open(path, "r") as open_file: # importando a query
        return open_file.read()
    
def date_range(start, stop): # função que retorna uma lista de datas
    dt_start = datetime.datetime.strptime(start, "%Y-%m-%d")
    dt_stop = datetime.datetime.strptime(stop, "%Y-%m-%d")
    dates = []
    while dt_start <= dt_stop:
        dates.append(dt_start.strftime("%Y-%m-%d"))
        dt_start += datetime.timedelta(days=1) # soma x dias
    return dates

def ingest_date(query, table, dt):

    query_fmt = query.format(date=dt) #colocando a data que quero no {date} da query

    df = pd.read_sql(query_fmt, origin_engine) # execura a query e traz o resultado para um df

    with target_engine.connect() as con: # deletando os dados com a data de ref para garantir integridade
        try:
            state = f"DELETE FROM {table} WHERE dtRef = '{dt}';"
            con.execute(sqlalchemy.text(state))
            con.commit()
        except exc.OperationalError as err:
            print("Tabela ainda não existe, criando ela...")

    df.to_sql(table, target_engine, index=False, if_exists='append') # enviando os dados para o novo database

 # %%

now = datetime.datetime.now().strftime("%Y-%m-%d")

parser = argparse.ArgumentParser()
parser.add_argument("--feature_store", "-f", help="Nome de feature store", type=str)
parser.add_argument("--start", "-s", help="Data de início", default=now, type=str)
parser.add_argument("--stop", "-p", help="Data de parada", default=now,  type=str)
args = parser.parse_args()

origin_engine = sqlalchemy.create_engine("sqlite:///../../data/database.db")
target_engine = sqlalchemy.create_engine("sqlite:///../../data/feature_store.db") 

query = import_query(f"{args.feature_store}.sql") 
dates = date_range(args.start, args.stop)

for i in tqdm(dates):
    ingest_date(query, args.feature_store, i)
# %%
 