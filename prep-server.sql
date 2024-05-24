IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'TestDB'
)
CREATE DATABASE TestDB;
GO

USE TestDB;
GO

IF NOT EXISTS (
    SELECT * FROM sys.tables WHERE name = 'TestTable'
)
CREATE TABLE TestTable (
    ID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    NullableString NVARCHAR(1024) NULL,
    NonNullableString NVARCHAR(1024) NOT NULL
);
GO

INSERT INTO TestTable (ID, NullableString, NonNullableString)
VALUES 
('3F2504E0-4F89-11D3-9A0C-0305E82C3301', NULL, 'Non-Nullable String 1'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3302', 'Nullable String 2', 'Non-Nullable String 2'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3303', 'Nullable String 3', 'Non-Nullable String 3'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3304', NULL, 'Non-Nullable String 4'),
('3F2504E0-4F89-11D3-9A0C-0305E82C3305', 'Nullable String 5', 'Non-Nullable String 5');
GO