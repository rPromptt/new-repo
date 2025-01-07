# %%
import snowcatcher
# Import the necessary module
# from dotenv import load_dotenv
# Load environment variables from the .env file (if present)
# load_dotenv()  £ not needed with the vscode reading the .env variables.
# Might be needed for deployment and when not runing code in vscode.

df = snowcatcher.connect_and_query(
    config_path='config.yaml',
    query_path='query.sql')
print(df.head())

# %%
