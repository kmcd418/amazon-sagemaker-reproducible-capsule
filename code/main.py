import pandas as pd
import yaml

with open('config.yaml', 'r') as file:
    config = yaml.safe_load(file)

df = pd.read_csv(config['run']['data'])
print(df.head())
df.to_parquet(config['run']['results'])

# if __name__ == '__main__':
#     print("HELLO WORLD!")