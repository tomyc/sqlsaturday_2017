sp_configure

EXEC sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE

--Weryfikacja poprawno�ci ustawienia zewn�trzych skrypt�w
EXEC sp_configure  'external scripts enabled'

--Weryfikacja poprawno�ci dzia�ania servisu Launchpad - poprawny wynik, warto�� 1
EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT 1 AS col'