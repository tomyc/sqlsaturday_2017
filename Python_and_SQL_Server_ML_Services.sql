USE master;
GO
RESTORE DATABASE TutorialDB
   FROM DISK = 'D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TutorialDB.bak'
   WITH
   MOVE 'TutorialDB' TO 'D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TutorialDB.mdf'
   ,MOVE 'TutorialDB_log' TO 'D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TutorialDB.ldf';
GO

USE tutorialdb;
SELECT * FROM [dbo].[rental_data];

