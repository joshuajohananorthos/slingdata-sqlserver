## Steps to Reproduce
1. Start SQL server: 
```sh
docker compose up --build
```
This will create a new database called `TestDB` with a table called `TestTable` and insert 5 rows. Schema for `TestTable`:
```sql
CREATE TABLE TestTable (
    ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    NullableString NVARCHAR(1024) NULL,
    NonNullableString NVARCHAR(1024) NOT NULL
);
```
Values inserted into `TestTable`:
```sql
INSERT INTO TestTable (ID, NullableString, NonNullableString)
VALUES 
('3F2504E0-4F89-11D3-9A0C-0305E82C3301', NULL, 'Non-Nullable String 1'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3302', 'Nullable String 2', 'Non-Nullable String 2'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3303', 'Nullable String 3', 'Non-Nullable String 3'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3304', NULL, 'Non-Nullable String 4'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3305', 'Nullable String 5', 'Non-Nullable String 5');
```

2. Run `test.sh` that will create a connection to the database and run `sling` with 3 different outputs: `json`, `csv`, and `parquet`. 
3. Run `python view_parquet.py` to view the contents of the `parquet` file.

## Observations
- `json` and `csv` will correctly output the `NULL` values correctly. And the `parquet` output will not output the `NULL` values as empty strings.

Here is the output of `python view_parquet.py`:
```
num_row_groups: 1
metadata: <pyarrow._parquet.FileMetaData object at 0x7466687672c0>
  created_by: github.com/parquet-go/parquet-go version 0.20.0(build )
  num_columns: 3
  num_rows: 5
  num_row_groups: 1
  format_version: 1.0
  serialized_size: 485
compression: SNAPPY
<pyarrow._parquet.ParquetSchema object at 0x74666d66ca40>
required group field_id=-1  {
  required binary field_id=-1 ID (String);
  required binary field_id=-1 NullableString (String);
  required binary field_id=-1 NonNullableString (String);
}

pyarrow.Table
ID: string not null
NullableString: string not null
NonNullableString: string not null
----
ID: [["e004253f-894f-d311-9a0c-0305e82c3301","e004253f-894f-d311-9a0c-0305e82c3302","e004253f-894f-d311-9a0c-0305e82c3303","e004253f-894f-d311-9a0c-0305e82c3304","e004253f-894f-d311-9a0c-0305e82c3305"]]
NullableString: [["","Nullable String 2","Nullable String 3","","Nullable String 5"]]
NonNullableString: [["Non-Nullable String 1","Non-Nullable String 2","Non-Nullable String 3","Non-Nullable String 4","Non-Nullable String 5"]]
```
Versus the `jsonl` output:
```json
{"id":"e004253f-894f-d311-9a0c-0305e82c3301","nonnullablestring":"Non-Nullable String 1","nullablestring":null}
{"id":"e004253f-894f-d311-9a0c-0305e82c3302","nonnullablestring":"Non-Nullable String 2","nullablestring":"Nullable String 2"}
{"id":"e004253f-894f-d311-9a0c-0305e82c3303","nonnullablestring":"Non-Nullable String 3","nullablestring":"Nullable String 3"}
{"id":"e004253f-894f-d311-9a0c-0305e82c3304","nonnullablestring":"Non-Nullable String 4","nullablestring":null}
{"id":"e004253f-894f-d311-9a0c-0305e82c3305","nonnullablestring":"Non-Nullable String 5","nullablestring":"Nullable String 5"}
```
- The UniqueIdentifier output is not the same as the value being input. I did not notice this before, but when I put this together it appears the sections values are reversed by byte. I investigated this and it appears SQL Server on Intel processors is using Little Endian. And it it not across all the bytes. I found this from the following https://dba.stackexchange.com/questions/121869/sql-server-uniqueidentifier-guid-internal-representation.

Bits | Bytes | Name |Endianness
---- | ----- | ---- | ---------
32 | 4 | Data1 | Native
16 | 2 | Data2 | Native
16 | 2 | Data3 | Native
64 | 8 | Data4 | Big

So if SQL Server is running on Intel the first 8 bytes are stored as Little Endian. I am assuming this is the source of the issue.


Section | SQL Server | Parsed UUID
------- | ---------- | -----------
Data1 | 3F2504E0 | E004253F
Data2 | 4F89 | 894F
Data3 | 11D3 | D311
Data4 | 9A0C-0305E82C3301 | 9A0C-0305E82C3301