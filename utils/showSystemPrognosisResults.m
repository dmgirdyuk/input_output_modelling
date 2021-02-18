function showSystemPrognosisResults(IOModels, dynIOModel, ...
    yearBaseInd, year2Analyze)
% Результаты собственного движения системы на основе предсказанных значений
% фондоемкостей

fprintf('========================================================\n')
fprintf('Прогноз значений выпусков (собственное движение системы)\n')
fprintf('========================================================\n')
% Прогноз значений выпусков
IPrev = vpa(dynIOModel.I);
Iyear2ANalyze = vpa(IOModels(yearBaseInd + 1).I);
sobstvDvijSyst = vpa(expm(dynIOModel.D) * IPrev);
relDiffSyst = vpa(((sobstvDvijSyst - Iyear2ANalyze) ./ ...
    Iyear2ANalyze * 100));

% Результаты
fprintf('==================================\n')
fprintf('Прогноз на %i год на основе %i\n', [year2Analyze, ...
    year2Analyze - 1])
fprintf('==================================\n')
fprintf('Выпуски в %i году:', year2Analyze - 1)
IPrev
fprintf('Выпуски в %i году:', year2Analyze)
Iyear2ANalyze
fprintf('Прогноз на %i год:', year2Analyze)
sobstvDvijSyst
fprintf('Относительная разница:')
relDiffSyst

% Прогноз на 2 года вперед
if year2Analyze <= 2014
    fprintf('==================================\n')
    fprintf('Прогноз на %i год на основе %i \n', [year2Analyze + 1, ...
        year2Analyze - 1])
    fprintf('==================================\n')
    fprintf('Выпуски в %i году:', year2Analyze - 1)
    IPrev
    fprintf('Выпуски в %i году:', year2Analyze + 1)
    vpa(IOModels(yearBaseInd + 2).I)
    fprintf('Прогноз на %i год:', year2Analyze + 1)
    sobstvDvijSyst2 = vpa(expm(dynIOModel.D * 2) * IPrev)
    fprintf('Относительная разница:')
    relDiffSyst2 = ...
        vpa(((sobstvDvijSyst2 - IOModels(yearBaseInd + 2).I) ./ ...
        IOModels(yearBaseInd + 2).I * 100))
end

end