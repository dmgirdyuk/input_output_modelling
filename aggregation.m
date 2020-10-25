function [Ia,Ra] = aggregation(Iw,Rw,aggregateIndustriesNumber)
% Процедура агрегирования.
%
% Использован код из книги
% Пересада В. П., Смирнов Н. В., Смирнова Т. Е. Статические и динамические
% модели многопродуктовой экономики: Учебное пособие. СПб : Издательский
% Дом Федоровой Г.В., 2017.
% 
% Входные параметры: вектор Iw и матрица Rw статической модели, вектор
% aggregateIndustriesNumber, задающий для каждого сектора экономики номер
% агрегированного сектора, в который он должен входить. Этот вектор дол-
% жен содержать все целые числа из промежутка [1, m], которые могут по-
% вторяться, если несколько секторов сливаются в один и тот же агрегиро-
% ванный сектор. Здесь m – количество новых агрегированных секторов.
% 
% Выходные параметры: вектор Ia и матрица Ra агрегированной статической
% модели.

% Количество агрегированных секторов
m = max(aggregateIndustriesNumber);

% Переменная типа cell, в ячейке с номером i содержатся номера секторов,
% которые войдут в i-й агрегированый сектор.
aggregateIndustry = cell(1,m);

Ia = zeros(m,1);
Ra = zeros(m);
industryAmount = 0;
for i = 1:m
    aggregateIndustry{i} = find(aggregateIndustriesNumber == i);
    Ia(i,1) = sum(Iw(aggregateIndustry{i},1));
    industryAmount = industryAmount + length(aggregateIndustry{i});
end
if industryAmount ~= size(aggregateIndustriesNumber,1)
    errordlg("Некорректный формат массива aggregateIndustriesNumber");
end
for i = 1:m
    for j = 1:m
        R1 = Rw(aggregateIndustry{i}, aggregateIndustry{j});
        I1 = Iw(aggregateIndustry{j});
        Ra(i,j) = sum(R1 * I1) / Ia(j,1);
    end
end
