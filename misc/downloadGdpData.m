function [] = downloadGdpData(yearFirst, yearLast)
% Сохраняет csv-файл с данными по ВВП (в US millions; в текущих ценах) за 
% период с [yearFirst, yearLast] в папке data/GDP

if nargin < 2
    yearFirst = 2005;
    yearLast = 2015;
end

% Загрузка данных по обменным курсам (нац. валюта / доллар США)
% Данные по обменным курсам можно выгрузить по ссылке:
% https://data.oecd.org/conversion/exchange-rates.htm
% csv-файл за 2005--2015 гг. находится в папке 'data/EXCHANGE_RATES'
exchTable = ...
    readtable("data\EXCHANGE_RATES\DP_LIVE_08012020114221589.csv");

% Парсинг xml-файла с данными по ВВП из БД OECD
% 
% OECD reference year changed from 2010 to 2015 on Tuesday 
% 3rd of December, 2019.
% This dataset is an archive of the Gross domestic product (GDP) 
% dataset as of the 27th June of 2019, prior to the 2019 benchmark 
% revisions. As it may happen that countries only cover results for 
% a limited time period when first publishing the results of their 
% benchmark revision, this dataset provides users with longer time 
% series based on the methodology as used before the benchmark 
% revision. In general, longer historical time series become 
% available after a certain amount of time
% 
% Доступ к последним на сегодняшний день данным можно получить, изменив
% в строке с url ниже "SNA_TABLE1_ARCHIVE" на "SNA_TABLE1"

urlGdp = ['https://stats.oecd.org/restsdmx/', ...
    'sdmx.ashx/GetData/SNA_TABLE1_ARCHIVE/', ...
    'AUS+AUT+BEL+CAN+CHL+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+', ...
    'IRL+ISR+ITA+JPN+KOR+LVA+LTU+LUX+MEX+NLD+NZL+NOR+POL+PRT+', ...
    'SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+ARG+BRA+BGR+CPV+CHN+COL+', ...
    'CRI+HRV+CYP+HKG+IND+IDN+MDG+MLT+MAR+MKD+PER+ROU+RUS+ZAF+', ...
    'ZMB.', ...
    'B1_GA.C/all?startTime=', num2str(yearFirst), ...
    '&endTime=', num2str(yearLast)];
gdpXmlTree = xml2struct(urlGdp);

% Таблицы межотраслевого баланса в БД OECD есть для 64 стран. 
% Однако данные по ВВП лишь по 57
N_COUNTRIES = 57;

yearColumn = [];
countryColumn = [];
valueGdpColumn = [];

for countryInd = 1:N_COUNTRIES
    % Не для всех стран есть данные за весь рассматриваемый период.
    yearNumb = length(gdpXmlTree.Children(2). ...
        Children(countryInd + 1).Children);
    
    for yearInd = 1:yearNumb - 2
        [~, curCountry] = gdpXmlTree.Children(2). ...
            Children(countryInd + 1).Children(1). ...
            Children(1).Attributes.Value;              
        countryColumn = [countryColumn; convertCharsToStrings(curCountry)];

        yearColumn = [yearColumn; 2004 + yearInd];
        
        % Данные по обменным курсам есть только для 55 стран
        if sum(strcmp(countryColumn(end), exchTable.LOCATION))
            exchRate = ...
                exchTable(strcmp(countryColumn(end), ...
                    exchTable.LOCATION) & ...
                    strcmp(int2str(yearColumn(end)), exchTable.TIME), 7);
            
            currentValueGdp = str2double(gdpXmlTree. ...
                Children(2).Children(countryInd + 1). ...
                Children(yearInd + 2).Children(2).Attributes.Value) / ... 
                exchRate.Value; 
        else
            currentValueGdp = 0;
        end
        
        valueGdpColumn = [valueGdpColumn; currentValueGdp];
    end
end

writetable(table(countryColumn, yearColumn, valueGdpColumn), ...
    'data/GDP/gdp1.csv'); 

end
