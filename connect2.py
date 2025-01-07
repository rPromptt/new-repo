# %%
import snowcatcher
# Import the necessary module
# from dotenv import load_dotenv
# Load environment variables from the .env file (if present)
# load_dotenv()  £ not needed with the vscode reading the .env variables
df = snowcatcher.connect_and_query(
    config_path='config2.yaml',
    query_path='query2.sql')
print(df.head())

# %%
