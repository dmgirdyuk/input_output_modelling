function inputOutputModels = ...
    dynamicInputOutputModel(countryName, aggregNumb, aggregSect)
% Построение динамической модели межотраслевого баланса (МОБ).
%
% Входные аргументы:
%     countryName -- трехсимвольная строка, кодификатор страны;
%     agregNumb -- целое из интервала [2, 37], количество агрегированных 
%       секторов (36 секторов в БД + ВВП);
%     aggregSect -- вектор-столбец размерности 1x37, компоненты которого
%       указывают вхождение экономического сектора в агрегированный сектор;
%     
% Выходные аргументы:
%     inputOutputModels -- массив структур, содержащих статические модели 
%       МОБ;

if ~exist('countryName', 'var') 
    countryName = 'USA';
end
if ~exist('aggregNumb', 'var') 
    aggregNumb = 4;
end
if ~exist('aggregSect', 'var') 
        % Описание агрегации (в 4 сектора) экономических секторов 
        % представлено в файле 'data/sectAggreg.xlsx'
        switch aggregNumb
            case 2
                aggregSect = [ones(N_SECT, 1); 2];
            case 4
                aggregSect = [ones(20, 1); 2 * ones(11, 1); ...
                    3 * ones(5, 1); 4];
            otherwise
                aggregSect = linspace(1, N_SECT + 1, N_SECT + 1)';       
        end
end

yearFirst = 2005;
yearLast = 2015;
yearDiff = yearLast - yearFirst + 1;

% Cтруктура, содержащая агрегированную статическую модель
% межотраслевого баланса
% Вектор-столбец выпусков экономики 
inputOutputModel.I = zeros(aggregNumb, 1); 
% Матрица статической модели
inputOutputModel.R = zeros(aggregNumb, aggregNumb); 
% Вектор-столбец инвестиций (для построения динамической модели)
inputOutputModel.Cp = zeros(aggregNumb, 1); 
% Показатели агрегированной экономики: 
% Вектор-столбец с долями промежуточного потребления в выпусках
inputOutputModel.rp = zeros(aggregNumb - 1, 1);
% Вектор-столбец с долями заработной платы в добавленных стоимостях
inputOutputModel.rw = zeros(aggregNumb - 1, 1);
% Вектор-столбец с долями чистых налогов на производство в добавленных
% стоимостях
inputOutputModel.rt = zeros(aggregNumb - 1, 1);
% Вектор-столбец с долями чистых налогов на продукцию в выпусках
inputOutputModel.tp = zeros(aggregNumb, 1);
% Вектор-столбец с долями инвестиций в чистой прибыли секторов
inputOutputModel.rn = zeros(aggregNumb, 1);

% Вектор-столбец фондоемкостей секторов
inputOutputModel.Fe = zeros(aggregNumb,1);
% Вспомогательная матрица динамической модели
inputOutputModel.M = zeros(aggregNumb,aggregNumb);

% Массив таких структур
inputOutputModels = repmat(inputOutputModel, 1, yearDiff);

% Выгружаем данные по ВВП для countryName 
gdp = readtable(fullfile('data', 'GDP', 'gdp.csv'));
countryRealGdp = ...
    table2array(gdp(strcmp(gdp.countryColumn, countryName), 3))';
% В БД OECD для некоторых стран есть таблицы МОБ, но нет информации по ВВП. 
% В таком случае сопоставление со значением ВВП, вычисленным на основе 
% таблиц МОБ не производится
if size(countryRealGdp) < yearDiff
    countryRealGdp = zeros(yearDiff);
end

% Формируем массив структур, содержащих информацию для построения
% статической модели МОБ
for yearInd = 1:yearDiff
    inputOutputModel = ...
        staticModelConstruction(yearFirst - 1 + yearInd, countryName, ...
            aggregNumb, countryRealGdp(yearInd), aggregSect, true);     
    inputOutputModels(yearInd) = inputOutputModel;
end

% Дополняем структуры (кроме структуры для последнего года) 
% коэффициентами фондоемкости и матрицами динамических моделей
for yearInd = 1:yearDiff - 1
    inputOutputModel = ...
        dynamicModelConstruction(inputOutputModels(yearInd + 1), ...
            inputOutputModels(yearInd));
    inputOutputModels(yearInd) = inputOutputModel;
end

end
