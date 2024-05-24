import pyarrow.parquet as pq

file = pq.ParquetFile('test.parquet')
print(f'num_row_groups: {file.num_row_groups}')
print(f'metadata: {file.metadata}')
print(f'compression: {file.metadata.row_group(0).column(0).compression}')
print(file.schema)
table = pq.read_table('test.parquet')
print(table)