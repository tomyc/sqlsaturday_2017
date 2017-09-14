-- 1. Przechowaj zbudowany model w tabeli rental_py_models

USE TutorialDB;
DROP TABLE IF EXISTS rental_py_models;
GO
CREATE TABLE rental_py_models (
	model_name VARCHAR(30) NOT NULL DEFAULT('default model') PRIMARY KEY,
	model VARBINARY(MAX) NOT NULL
);
GO

-- 2. Stwórz procedurê sk³adowan¹, która zbuduje model na podstawie danych z tabeli rental_data 
-- i z zastosowaniem algorytmu regresji liniowej

DROP PROCEDURE IF EXISTS generate_rental_py_model;
GO


CREATE PROCEDURE generate_rental_py_model (@trained_model varbinary(max) OUTPUT)
AS
BEGIN
    EXECUTE sp_execute_external_script
      @language = N'Python'
    , @script = N'
#To juz jest Python ;)

from sklearn.linear_model import LinearRegression #model regresji liniowej
import pickle #serializacja obiektu, zbudowany model mo¿na zamkn¹æ do tabeli z bazie

df = rental_train_data

# Pobierz wszystkie kolumny z obiektu DataFrame.
columns = df.columns.tolist()

# Jaka zmienna i przewidywanie jej wartoœci jest dla nas celem obracowywanego modelu
target = "RentalCount"

# Inicjalizacja instancji klasy LinearRegression
lin_model = LinearRegression()

# Dopasuj model do danych 
lin_model.fit(df[columns], df[target])

#Zamin bêdziemy mogli zapisaæ model do bazy musimy przekonwertowaæ go do obiektu binarnego
#Przypisany jest on do zmiennej trained_model
trained_model = pickle.dumps(lin_model)'

, @input_data_1 = N'select "RentalCount", "Year", "Month", "Day", "WeekDay", "Snow", "Holiday" from dbo.rental_data where Year < 2015'
, @input_data_1_name = N'rental_train_data'
, @params = N'@trained_model varbinary(max) OUTPUT'
, @trained_model = @trained_model OUTPUT;
END;
GO

-- 3. Zapisz zbudowany i przekonwertowany model do wczeœniej przygotowanej tabeli rental_py_models
-- w bazie 

TRUNCATE TABLE rental_py_models;

DECLARE @model VARBINARY(MAX);
EXEC generate_rental_py_model @model OUTPUT;

INSERT INTO rental_py_models (model_name, model) VALUES('linear_model', @model);

-- ------------------------------------ Model ju¿ ¿yje --------------------------

-- Model dzia³a i przewiduje

-- 1. Stwórz procedurê sk³adowan¹, która zastosuje model do predykcji danych

DROP PROCEDURE IF EXISTS py_predict_rentalcount;
GO

CREATE PROCEDURE py_predict_rentalcount (@model varchar(100))
AS
BEGIN
	DECLARE @py_model varbinary(max) = (select model from rental_py_models where model_name = @model);

	EXEC sp_execute_external_script
				@language = N'Python',
				@script = N'

# Zaimportuj funkcje i pakiety do rozpakowania modelu i potrzebych dalszych obliczeñ
from sklearn.metrics import mean_squared_error
import pickle 
import pandas as pd

#Pobierz model, odpakuj i przypisz do zmiennej rental_model
rental_model = pickle.loads(py_model) 

df = rental_score_data

# Pobierz wszystkie kolumny z obiektu DataFrame
columns = df.columns.tolist()

# Jaka zmienna nas interesuje w jej predykcji?
target = "RentalCount"

# Wygeneruj wartoœci dla zbioru testowego
lin_predictions = rental_model.predict(df[columns])
print(lin_predictions)

# Oblicz b³¹d jaki jest pomiêdzy danymi rzeczywistymi a prognozowanymi
lin_mse = mean_squared_error(lin_predictions, df[target])
#print(lin_mse)

predictions_df = pd.DataFrame(lin_predictions)

OutputDataSet = pd.concat([predictions_df, df["RentalCount"], df["Month"], df["Day"], df["WeekDay"], df["Snow"], df["Holiday"], df["Year"]], axis=1)
'
, @input_data_1 = N'Select "RentalCount", "Year" ,"Month", "Day", "WeekDay", "Snow", "Holiday"  from rental_data where Year = 2015'
, @input_data_1_name = N'rental_score_data'
, @params = N'@py_model varbinary(max)'
, @py_model = @py_model
with result sets (("RentalCount_Predicted" float, "RentalCount" float, "Month" float,"Day" float,"WeekDay" float,"Snow" float,"Holiday" float, "Year" float));

END;
GO

-- 2. Mo¿emy ju¿ prognozowaæ wartoœci dla zmiennej "RentalCount", 
-- wiêc zapiszmy wyniki prognozy do tabeli

DROP TABLE IF EXISTS [dbo].[py_rental_predictions];
GO

--Stwórz tablê przechowuj¹c¹ prognozy
CREATE TABLE [dbo].[py_rental_predictions](
 [RentalCount_Predicted] [int] NULL,
 [RentalCount_Actual] [int] NULL,
 [Month] [int] NULL,
 [Day] [int] NULL,
 [WeekDay] [int] NULL,
 [Snow] [int] NULL,
 [Holiday] [int] NULL,
 [Year] [int] NULL
) ON [PRIMARY]
GO

-- 3. Uruchamiamy procedurê sk³adowan¹ py_predict_rentalcount
TRUNCATE TABLE py_rental_predictions;
-- i wyniki jej dzia³ania na danych testowych zapisujemy do tabeli bazy danych
INSERT INTO py_rental_predictions
EXEC py_predict_rentalcount 'linear_model';

-- Czy coœ wysz³o?
SELECT * FROM py_rental_predictions;
