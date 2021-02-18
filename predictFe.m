function FePred = predictFe(year2Analyze, IOModels, FePredMethod) 
% Построение прогноза для значений фондоемкостей в рассматриваемый год

yearStart = 2005;
years = linspace(yearStart, ...
    year2Analyze - 2, ...
    year2Analyze - yearStart - 1);

% Фондоемкости 
FeModel = horzcat(IOModels(years - yearStart + 1).Fe);
FeModelPrevYear = IOModels(year2Analyze - yearStart).Fe;
FePred = [];
agregNumb = size(FeModel, 1);

switch FePredMethod
    case 'prev'
        FePred = FeModel(:, end);
        
    case 'mean'
        yearsNumb = 3;
        FePred = mean(FeModel(:, end - yearsNumb + 1:end), 2);
        
    case 'inputs'
        % Выпуски в рассматриваемые годы
        IModel = horzcat(IOModels(years - yearStart + 1).I);
        % Последовательные разницы между выпусками
        deltaI = IModel(:, 2:end) - IModel(:, 1:end - 1);
        % Разница между анализируемым годом и предшествующим ему
        deltaIyear2Analyze = IOModels(year2Analyze - yearStart + 1).I - ...
            IOModels(year2Analyze - yearStart).I;
        % Степень подгоняемого к данным полинома
        polyDegree = 1;
        % Матрица с коэффициентами полиномов
        modelCoef = [];
        
        for k = 1:agregNumb
            modelCoef(k, :) = polyfit(deltaI(k,:), FeModel(k,2:end), ...
                polyDegree);
            FePred(k, 1) = polyval(modelCoef(k, :), ...
                deltaIyear2Analyze(k, 1));
        end
        % Графики прогнозов фондоемкостей
        for k = 1:agregNumb
            figure(k) 
            plot([years(2:end), year2Analyze - 1], ...
                [FeModel(k,2:end), FeModelPrevYear(k, 1)], ...
                [years(2:end), year2Analyze - 1], ...
                polyval(modelCoef(k, :), ...
                    [deltaI(k, :), deltaIyear2Analyze(k, 1)]))
            legend('Реальные', 'Прогноз')
            grid
        end
        
    case 'years'
        % Степень подгоняемого к данным полинома
        polyDegree = 1;
        % Матрица с коэффициентами полиномов
        modelCoef = [];
        
        for k = 1:agregNumb
            modelCoef(k, :) = polyfit(years(1:end), FeModel(k,:), ...
                polyDegree);
            FePred(k, 1) = polyval(modelCoef(k, :), ...
                year2Analyze - 1);
        end
        % Графики прогнозов фондоемкостей
        for k = 1:agregNumb
            figure(k) 
            plot([years(2:end), year2Analyze - 1], ...
                [FeModel(k,:), FeModelPrevYear(k, 1)], ...
                [years(2:end), year2Analyze - 1], ...
                polyval(modelCoef(k, :), ...
                    [years(2:end), year2Analyze - 1]))
            legend('Реальные', 'Прогноз')
            grid
        end
end

end