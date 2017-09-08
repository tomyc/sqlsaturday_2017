sp_configure

EXEC sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE

--Weryfikacja poprawnoœci ustawienia zewnêtrzych skryptów
EXEC sp_configure  'external scripts enabled'

--Weryfikacja poprawnoœci dzia³ania servisu Launchpad - poprawny wynik, wartoœæ 1
EXEC sp_execute_external_script  @language =N'Python',
@script=N'OutputDataSet=InputDataSet',
@input_data_1 = N'SELECT 1 AS col'