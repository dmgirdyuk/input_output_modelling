function showFePrognosisResults(IOModels, dynIOModel, ...
    yearStart, year2Analyze)

fprintf('=====================\n')
fprintf('Прогноз фондоемкостей\n')
fprintf('=====================\n')
fprintf('Фондоемкости в %i году: ', year2Analyze - 1)
FeModelPrevYear = IOModels(year2Analyze - yearStart).Fe
fprintf('Прогноз фондоемкостей на тот же год: ')
dynIOModel.FePred

end