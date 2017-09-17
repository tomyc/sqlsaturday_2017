-- Włączenie obsługi skryptów

sp_configure 'external scripts enabled','1'
reconfigure with override
go


-- Lista pakietow Pythona

exec sp_execute_external_script  @language =N'Python',
@script=N'import pip
import pandas as pd

installed_packages = pip.get_installed_distributions()
installed_packages_list = sorted(["%s %s" % (i.key,i.version) for i in installed_packages])
print(installed_packages_list)
OutputDataSet = pd.DataFrame(installed_packages_list)'


-- Wersja pythona i sciezki

exec sp_execute_external_script
       @language = N'Python'
       , @script = N'
import sys
import pkg_resources
OutputDataSet = pandas.DataFrame(
                    {"property_name": ["Python.home", "Python.version", "Revo.version", "libpaths"],
                    "property_value": [sys.executable[:-10], sys.version, pkg_resources.get_distribution("revoscalepy").version, str(sys.path)]}
)
'
WITH RESULT SETS ((PropertyName nvarchar(100), PropertyValue nvarchar(4000)));


-- Wygenerowanie i wyswietlenie randomowych liczb (Dan Buskirk)

exec sp_execute_external_script @language =N'Python',

@script=N'

import random

import pandas as pd

t=[]

for i in range(0,10):

 t.append(random.random())

tDF = pd.DataFrame(data=t)

newnames={0:"Random"}

tDF.rename(columns=newnames, inplace=True)

print(tDF)

OutputDataSet=tDF'

WITH RESULT SETS (([Random Value] float))

-- Uprawnienia do wykonywania external scripts

USE master
GO
GRANT EXECUTE ANY EXTERNAL SCRIPT  TO test


-- resource pools

SELECT * FROM sys.resource_governor_resource_pools WHERE name = 'default'     --default pool
SELECT * FROM sys.resource_governor_external_resource_pools WHERE name = 'default'  --default external pool

ALTER EXTERNAL RESOURCE POOL "default" WITH (max_memory_percent = 40);  --modify default external pool
ALTER RESOURCE GOVERNOR reconfigure;  --apply changes


-- DMV's

sys.dm_exec_sessions
sys.dm_os_performance_counters (SELECT * from sys.dm_os_performance_counters WHERE object_name LIKE '%External Scripts%')
sys.dm_external_script_requests
sys.dm_external_script_execution_stats



