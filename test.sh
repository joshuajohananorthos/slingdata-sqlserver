#!/bin/bash

export LOCAL_SQLSERVER='sqlserver://sa:Simplepassword1@localhost:1433/?database=TestDB&encrypt=true&TrustServerCertificate=true'
sling conns list
sling run --src-conn LOCAL_SQLSERVER --src-stream 'dbo.TestTable' --tgt-conn 'file://test.parquet' 
sling run --src-conn LOCAL_SQLSERVER --src-stream 'dbo.TestTable' --tgt-conn 'file://test.jsonl'
sling run --src-conn LOCAL_SQLSERVER --src-stream 'dbo.TestTable' --tgt-conn 'file://test.csv'  