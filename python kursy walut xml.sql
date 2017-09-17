CREATE TABLE #Waluty(waluta char(4),kupno nvarchar(max), sprzedaz nvarchar(max))

insert into #Waluty exec 
sp_execute_external_script @language =N'Python',
@script=N'
from xml.dom import minidom
import urllib.request
import pandas as pd
 
url = ''http://www.nbp.pl/kursy/xml/c176z170912.xml''
dom = minidom.parse(urllib.request.urlopen(url)) 

kod = []
kupno = []
sprzedaz = []
cNodes = dom.childNodes
for i in cNodes[0].getElementsByTagName("pozycja"):
 kod.append(i.getElementsByTagName("kod_waluty")[0].childNodes[0].toxml())
 kupno.append(i.getElementsByTagName("kurs_kupna")[0].childNodes[0].toxml())
 sprzedaz.append(i.getElementsByTagName("kurs_sprzedazy")[0].childNodes[0].toxml())

tDF = pd.DataFrame(data=kod, columns = [''waluta''])
tDF[''kupno''] = pd.Series(kupno,index=tDF.index)
tDF[''sprzedaz''] = pd.Series(sprzedaz)
OutputDataSet=tDF
'

select * from  #Waluty
drop table #Waluty
