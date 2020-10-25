function inputOutputModel = staticModelConstruction(year, countryName, ...
    aggregNumb, countryRealGdp, aggregSect)
% Построение статической модели МОБ на основе таблицы БД OECD
% 
%     Входные аргументы:
%     year -- год из интервала [2005, 2015];
%     countryName -- трехсимвольная строка, кодификатор страны;
%     aggregNumb -- количество агрегированных секторов;
%     countryRealGdp -- ВВП countryName;
%     aggregSect -- вектор-столбец размерности 1x37, компоненты которого
%     указывают вхождение экономического сектора в агрегированный сектор.
% 
%     Выходной аргумент:
%     inputOutputModel -- структура, содержащая компоненты статической
%     модели МОБ

% Количество секторов экономики в таблицах OECD
N_SECT = 36;

% Обработка отсутствующих входных аргументов
if nargin < 5
    if exist('aggregNumb', 'file') 
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
    if nargin < 4
        countryRealGdp = 0;
        if nargin < 3
            aggregNumb = 4;
            aggregSect = [ones(20, 1); 2 * ones(11, 1); 3 * ones(5, 1); 4];
            if nargin < 2
                countryName = "DEU";
                if nargin < 1
                    year = 2005;
                end
            end    
        end
    end
end

% Архивы с таблицами МОБ и расширенной информацией по добавленным
% стоимостям можно скачать по ссылке: 
% https://stats.oecd.org/Index.aspx?DataSetCode=IOTSI4_2018#
% Export -> Related files
% NATIODOMINP.zip, VAROW.zip
% Архивы распакованы в папке 'data/'
% Файл с добавленными стоимостями VAROW.csv содержит UTF-16 маркер
% последовательности байтов, не воспринимаемый матлабом.
% Скрипт thirdparty/utf16Fix.m решает проблему
tDomImp = readtable(fullfile('data', 'NATIODOMIMP', countryName, ...
    num2str(year), 'dom.csv'));
tValueAdded = readtable(fullfile('data', 'VAROW', 'VAROW_ascii.csv'), ...
    'Delimiter', '|', 'ReadVariableName', false);
% tDomImp = readtable(join(['data/NATIODOMIMP/', ...
%     countryName, num2str(year), 'dom.csv'], ''));
% tValueAdded = readtable('data/VAROW/VAROW_ascii.csv', ...
%     'Delimiter', '|', 'ReadVariableName', false);

% Матрица промежуточных затрат Zd (внутри страны)
Zd = table2array(tDomImp(1:N_SECT, 2:N_SECT + 1));

% Матрица промежуточных затрат Zm (на импорт)
Zm = table2array(tDomImp(N_SECT + 1:2 * N_SECT, 2:N_SECT + 1));

% Матрица чистых налогов на промежуточную продукцию 
% Tproducts(уплаченные вне и внутри страны соответственно)
TProducts = table2array(tDomImp(2 * N_SECT + 1:2 * N_SECT + 2, ...
    2:N_SECT + 1));

% Матрица чистых налогов на конечную продукцию TFinProducts
TFinProducts = table2array(tDomImp(2 * N_SECT + 1:2 * N_SECT + 2, ...
    N_SECT + 2:N_SECT + 9));

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
C = table2array(tDomImp(1:N_SECT, ...
    N_SECT + 2:N_SECT + 3));

% Вектор затрат государства на конечное потребление G
G = table2array(tDomImp(1:N_SECT, ...
    N_SECT + 4));

% Матрица инвестиций I
I = table2array(tDomImp(1:N_SECT, ...
    N_SECT + 5:N_SECT + 6));

% Матрица экспорта Ex
Ex = table2array(tDomImp(1:N_SECT, ...
    N_SECT + 8:N_SECT + 9));

% Строка выпуска X
X = table2array(tDomImp(2 * N_SECT + 5, 2:N_SECT + 1));

% % столбец выпуска X -- таблицы OECD не являются полностью
% % сбалансированными, поэтому необходимо скорректировать вектор Y на
% % величину отклонения (хоть и незначительную)
% Xc = table2array(tDomImp(1:N_SECT, ...
%     N_SECT + 11));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Выпуски
X = (X - TProducts(1, :))';
% X = X';

% Строка добавленной стоимости
VA = W + TProduction + Gops;

% Инвестиции
I = sum(I,2);

% ВВП
GDP = sum(VA) + sum(TProducts(2, :)) + sum(TFinProducts(2, :));

% вектор конечного спроса
Y = sum(C, 2) + G + sum(I, 2) + sum(Ex, 2) - sum(Zm, 2) - TProducts(1, :)';
% Y = sum(C, 2) + G + sum(I, 2) + sum(Ex, 2) - sum(Zm, 2);

sum(VA + TProducts(2, :))
sum(Y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% вычисление расширенной матрицы технологических коэффициентов
n = size(X,1);
for j = 1 : n
    if X(j) ~= 0
        A(:,j) = (Zd(:,j) + Zm(:,j)) / X(j);
        VAr(j) = (VA(j) + TProducts(2,j)) / X(j);
    else
        A(:,j) = 0;
        VAr(j) = 0;
    end
end

% коррекция балансовых соотношений
err = X - A * X - Y;
Y = Y + err;

X = [X; GDP];
A = [A, Y / GDP; VAr, sum(TFinProducts(2,:)) / GDP];

% контроль
showStats = 0;
if showStats
    fprintf('%.0f год \n', vpa(year))
    fprintf('Истинное значение ВВП страны: %.4f \n', vpa(countryRealGdp))
    fprintf('ВВП страны на основе таблиц МОБ: %.4f \n', vpa(GDP))
    fprintf('Относительная ошибка ВВП: %.2f(%) \n', ...
        vpa((countryRealGdp - GDP) / countryRealGdp * 100))
    fprintf('norm(X - AX)): %.4f \n', ...
        vpa(norm(X - A * X)))
end

% агрегирование
Xa = zeros(aggregNumb,1);
Aa = zeros(aggregNumb,aggregNumb);
Ia = zeros(aggregNumb - 1,1);

if aggregNumb ~= size(X,1)
    [Xa, Aa] = aggregation(X,A,aggregSect);
end

% вычисление показателей агрегированной экономики
rp = zeros(agregN - 1,1);
rw = zeros(agregN - 1,1);
rt = zeros(agregN - 1,1);
tp = zeros(agregN,1); 
rn = zeros(agregN,1);

for k = 1 : agregN - 1
    tmpind = find(aggregSect == k)';
    rp(k) = 1 - Aa(agregN,k);
    rw(k) = sum(W(tmpind)) / sum(VA(tmpind));
    rt(k) = sum(TProduction(tmpind)) / sum(VA(tmpind));
    tp(k) = sum(TProducts(2,tmpind)) / Xa(k);
    Ia(k) = sum(I(tmpind));
end
tp(agregN) = Aa(agregN,agregN); 

rn(1:end - 1,1) = Ia ./ ...
    ((1 - rp - tp(1:end - 1)) .* (1 - rw - rt) .* Aa(1:end - 1,:) * Xa);
rn(end,1) = sum(Ia) / (Aa(end,:) * Xa);

end



