/* Copyright (c) 2017 Agnieszka Cieplak
 *
 * It is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with CERMINE. If not, see <http://www.gnu.org/licenses/>.
 */
 
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
