function [inputOutputModels, dynamicModel] = ...
    dynamicInputOutputMain(countryName, aggregNumb, aggregSect)
% Построение динамической модели межотраслевого баланса (МОБ).
%
%     Входные аргументы:
%     countryName -- трехсимвольная строка, кодификатор страны;
%     agregNumb -- целое из интервала [2, 37], количество агрегированных 
%     секторов (36 секторов в БД + ВВП);
%     aggregSect -- вектор-столбец размерности 1x37, компоненты которого
%     указывают вхождение экономического сектора в агрегированный сектор.
%     
%     Выходные аргументы:
%     inputOutputModels -- массив структур, содержащих статические модели 
%     МОБ с атрибутами: TODO
%     dynamicModel -- структура, содержащая динамическую модель МОБ с
%     атрибутами: TODO

% Обработка отсутствующих входных аргументов
if nargin < 3
    if exist('aggregNumb','file') 
        % Описание агрегации (в 4 сектора) экономических секторов 
        % представлено в файле sectAggreg.xlsx
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
    if nargin < 2
        aggregNumb = 4;
        aggregSect = [ones(20, 1); 2 * ones(11, 1); 3 * ones(5, 1); 4];
        if nargin < 1
            countryName = "DEU";
        end    
    end
end

addpath('thirdparty')

yearFirst = 2005;
yearLast = 2015;

yearDiff = yearLast - yearFirst + 1;

% Cтруктура, содержащая агрегированную статическую модель
% межотраслевого баланса
% Вектор-столбец выпусков экономики 
inputOutputModel.X = zeros(aggregNumb, 1); 
% Матрица статической модели
inputOutputModel.A = zeros(aggregNumb, aggregNumb); 
% Вектор-столбец инвестиций (для построения динамической модели)
inputOutputModel.I = zeros(aggregNumb, 1); 
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

% Массив таких структур
inputOutputModels = repmat(inputOutputModel, 1, yearDiff);

% Выгружаем данные по ВВП для countryName за период   
% Скрипт misc/downloadGdpData.m скачивает и парсит данные по ВВП
gdp = readtable(fullfile('data', 'GDP', 'gdp.csv'));
countryRealGdp = ...
    table2array(gdp(strcmp(gdp.countryColumn, countryName), 3))';
% В БД OECD для некоторых стран есть таблицы МОБ, но нет информации по ВВП. 
% В таком случае сопоставление со значением ВВП, вычисленным на основе 
% таблиц МОБ не производится
if size(countryRealGdp) < yearDiff
    countryRealGdp = zeros(yearDiff);
end

for yearInd = 1:yearDiff
    inputOutputModel = ...
        staticModelConstruction(yearFirst - 1 + yearInd, countryName, ...
        aggregNumb, countryRealGdp(yearInd), aggregSect); 
    break
    
    inputOutputModels(yearInd) = inputOutputModel;
end

end
        





%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Дополняем структуры (кроме структуры для первого года) 
%         % коэффициентами фондоемкости и матрицами динамических моделей

% % матрицы M для построения матриц динамических систем
% Fe = zeros(agregN,year_diff - 1);
% Ma = zeros(agregN,agregN,year_diff);
% FeN = zeros(agregN,year_diff - 1);
% MaN = zeros(agregN,agregN,year_diff);


%         if yearInd ~= 1
%             [Fe(:,yearInd - 1), Ma(:,:,yearInd - 1)] =...
%                 DynamicModelConstruction(Xa(:,yearInd),Xa(:,yearInd - 1),...
%                               rp(:,yearInd - 1),rw(:,yearInd - 1),rt(:,yearInd - 1),...
%                               tp(:,yearInd - 1),rn(:,yearInd - 1));
%             [FeN(:,yearInd - 1), MaN(:,:,yearInd - 1)] =...
%                 DynamicModelConstruction1(Xa(:,yearInd),Xa(:,yearInd - 1),...
%                               Ia(:,yearInd - 1),...
%                               rp(:,yearInd - 1),rw(:,yearInd - 1),rt(:,yearInd - 1),...
%                               tp(:,yearInd - 1),rn(:,yearInd - 1));
%         end
%     end 
% 
%     for k = 6 : 14
%         k + 2000
%         XaNext = expm(MaN(:,:,k) * Aa(:,:,k)) * Xa(:,k);
%         vpa(Xa(:,k))
%         vpa(Xa(:,k + 1))
%         vpa(XaNext)
%         rel_diff_next_forecast = ((Xa(:,k + 1) - XaNext) ./ Xa(:,k + 1) * 100)
%     end

% end
