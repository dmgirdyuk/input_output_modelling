function inputOutputModel = staticModelConstruction(year, countryName, ...
    aggregNumb, countryRealGdp, aggregSect, showStats)
% Построение статической модели МОБ на основе таблицы БД OECD
% 
% Входные аргументы:
%     year -- год из интервала [2005, 2015];
%     countryName -- трехсимвольная строка, кодификатор страны;
%     aggregNumb -- количество агрегированных секторов;
%     countryRealGdp -- ВВП countryName;
%     aggregSect -- вектор-столбец размерности 1x37, компоненты которого
%       указывают вхождение экономического сектора в агрегированный сектор;
%     showStats -- проверка подсчета ВВП по таблицам МОБ и выполнения 
%       балансовых соотношений модели;
% 
% Выходной аргумент:
%     inputOutputModel -- структура, содержащая компоненты статической
%       модели МОБ;

% Количество секторов экономики в таблицах OECD
nSect = 36;

if ~exist('year', 'var')
    year = 2005;
end
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
                aggregSect = [ones(nSect, 1); 2];
            case 4
                aggregSect = [ones(20, 1); 2 * ones(11, 1); ...
                    3 * ones(5, 1); 4];
            otherwise
                aggregSect = linspace(1, nSect + 1, nSect + 1)';       
        end
end
if ~exist('countryRealGdp', 'var') 
    countryRealGdp = 0;
end
if ~exist('showStats', 'var') 
    showStats = true;
end

% Подробная информация об источниках данных содержится в файле
% 'data/data_sources.txt'
tDomImp = readtable(fullfile('data', 'NATIODOMIMP', join([countryName, ...
    num2str(year), 'dom.csv'], '')));
tValueAdded = readtable(fullfile('data', 'VAROW', 'VAROW_ascii.csv'), ...
    'Delimiter', '|', 'ReadVariableName', false);

% Матрица промежуточных затрат Pd (внутри страны)
Pd = table2array(tDomImp(1:nSect, 2:nSect + 1));

% Матрица промежуточных затрат Zm (на импорт)
Pm = table2array(tDomImp(nSect + 1:2 * nSect, 2:nSect + 1));

% Матрица чистых налогов на промежуточную продукцию 
% Tproducts(уплаченные вне и внутри страны соответственно)
TProducts = table2array(tDomImp(2 * nSect + 1:2 * nSect + 2, ...
    2:nSect + 1));

% Матрица чистых налогов на конечную продукцию TFinProducts
TFinProducts = table2array(tDomImp(2 * nSect + 1:2 * nSect + 2, ...
    nSect + 2:nSect + 9));

% Строка оплаты труда W
W = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'LABR'), ...
    6))';

% Строка чистых налогов на промежуточное производство Tproduction
TProduction = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'OTXS'), ...
    6))';

% Строка валового операционного профицита и смешанного дохода GOPS
Gops = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'GOPS'), ...
    6))';

% Матрица конечного потребления домашних хозяйств C
C = table2array(tDomImp(1:nSect, ...
    nSect + 2:nSect + 3));

% Вектор затрат государства на конечное потребление G
G = table2array(tDomImp(1:nSect, ...
    nSect + 4));

% Матрица инвестиций Cp
Cp = table2array(tDomImp(1:nSect, ...
    nSect + 5:nSect + 6));

% Матрица экспорта Ex
Ex = table2array(tDomImp(1:nSect, ...
    nSect + 8:nSect + 9));

% Строка выпуска I
I = table2array(tDomImp(2 * nSect + 5, 2:nSect + 1));

% Выпуски
I = (I - TProducts(1, :))';

% Строка добавленной стоимости
VA = W + TProduction + Gops;

% Инвестиции
Cp = sum(Cp,2);

% ВВП
GDP = sum(VA) + sum(TProducts(2, :)) + sum(TFinProducts(2, :));

% вектор конечного спроса
Y = sum(C, 2) + G + sum(Cp, 2) + ...
    sum(Ex, 2) - sum(Pm, 2) - TProducts(1, :)';

% вычисление расширенной матрицы технологических коэффициентов
n = size(I, 1);
for j = 1 : n
    if I(j) ~= 0
        R(:, j) = (Pd(:, j) + Pm(:, j)) / I(j);
        VAr(j) = (VA(j) + TProducts(2, j)) / I(j);
    else
        R(:, j) = 0;
        VAr(j) = 0;
    end
end

% столбец выпуска I -- таблицы OECD не являются полностью
% сбалансированными, поэтому необходимо скорректировать вектор Y на
% величину отклонения (хоть и незначительную)
err = I - R * I - Y;
Y = Y + err;

I = [I; GDP];
R = [R, Y / GDP; VAr, sum(TFinProducts(2, :)) / GDP];

% контрольное сравнение
if showStats
    fprintf('%.0f год \n', vpa(year))
    fprintf('Истинное значение ВВП страны: %.4f \n', vpa(countryRealGdp))
    fprintf('ВВП страны на основе таблиц МОБ: %.4f \n', vpa(GDP))
    fprintf('Относительная ошибка ВВП: %.2f%% \n', ...
        vpa((countryRealGdp - GDP) / countryRealGdp * 100))
    fprintf('norm(I - RI)): %.4f \n\n', ...
        vpa(norm(I - R * I)))
end

% агрегирование
Ia = zeros(aggregNumb, 1);
Ra = zeros(aggregNumb, aggregNumb);
Cpa = zeros(aggregNumb - 1, 1);

if aggregNumb ~= size(I,1)
    [Ia, Ra] = aggregation(I, R, aggregSect);
end

% вычисление показателей агрегированной экономики
rp = zeros(aggregNumb - 1, 1);
rw = zeros(aggregNumb - 1, 1);
rt = zeros(aggregNumb - 1, 1);
tp = zeros(aggregNumb, 1); 
rn = zeros(aggregNumb, 1);

for k = 1 : aggregNumb - 1
    tmpind = find(aggregSect == k)';
    rp(k) = 1 - Ra(aggregNumb,k);
    rw(k) = sum(W(tmpind)) / sum(VA(tmpind));
    rt(k) = sum(TProduction(tmpind)) / sum(VA(tmpind));
    tp(k) = sum(TProducts(2,tmpind)) / Ia(k);
    Cpa(k) = sum(Cp(tmpind));
end
tp(aggregNumb) = Ra(aggregNumb, aggregNumb); 

rn(1:end - 1, 1) = Cpa ./ ...
    ((1 - rp - tp(1:end - 1)) .* (1 - rw - rt) .* Ia(1:end - 1));
rn(end, 1) = sum(Cpa) / (Ia(end));

% создание окончательной структуры, содержащей информацию о 
% статической модели
inputOutputModel.I = Ia;
inputOutputModel.R = Ra;
inputOutputModel.Cp = Cpa;
inputOutputModel.rp = rp;
inputOutputModel.rw = rw;
inputOutputModel.rt = rt;
inputOutputModel.tp = tp;
inputOutputModel.rn = rn;

inputOutputModel.Fe = zeros(aggregNumb, 1);
inputOutputModel.M = zeros(aggregNumb, aggregNumb);

fprintf('norm(I - RI)): %.4f \n\n', ...
    vpa(norm(inputOutputModel.I - inputOutputModel.R * inputOutputModel.I)))

end
