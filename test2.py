import pandas as pd
from sqlalchemy import create_engine
from snowflake.sqlalchemy import URL
user = 'kingsley.nwosu@leyland-trust.co.uk'
datab = 'DAF_DB'
sche = 'DAF_CONNECT'
ACCOUNT = 'paccar'
wh = 'DAF_EHV_53_000_MEDIUM_WH'
role = 'DAF_53000_CONNECT_R'
url = URL(
    account=ACCOUNT,
    user=user,
    authenticator='externalbrowser',
    warehouse=wh,
    role=role,
    database=datab,
    schema=sche,
    )
engine = create_engine(url)
connection = engine.connect()
query = 'select* from "Z_DM1_INJECTOR_RAISED_CLEARED" limit 5'  # your query
all_database = pd.read_sql(query, connection)
print(all_database)
