# %%
import pandas as pd
from sqlalchemy import create_engine
from snowflake.sqlalchemy import URL
import urllib.parse

user = 'n-DAF_53140_CA_ANALYTICS_DWH_SVC'
quoted_password = urllib.parse.quote('cWMvObSCDl')
datab = 'DAF_DB'
sche = 'CA_ANALYTICS_DWH'
ACCOUNT = 'paccar'
wh = 'DAF_EHV_53_140_XSMALL_WH'
role = 'SVC_DAF_53140_CA_ANALYTICS_DWH'
url = URL(
            account=ACCOUNT,
            user=user,
            password=quoted_password,
            warehouse=wh,
            role=role,
            database=datab,
            schema=sche,
            )

engine = create_engine(url)
connection = engine.connect()  # query_mul
query = 'select* from "DWH_DATAMART_DBO_DIM_WARR_CLAIM" limit 5'
all_database = pd.read_sql(query, connection)
print(all_database)
# %%
