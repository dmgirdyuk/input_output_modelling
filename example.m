function controlProblem = ...
    example(countryName, year2Analyze, FePredMethod, controlMode)
% Скрипт для воспроизведение примеров из книги
%
% Входные аргументы:
%     countryName -- трехсимвольная строка, кодификатор страны;
%     year2Analyze -- год из интервала [2006, 2014];
%     FePredMethod -- способ предсказания значений фондоемкостей для
%       year2Analyze - 1, опции: prev, mean, inputs, years
%     controlMode -- тип системы управления, опции: none, rw or tp;

if ~exist('countryName', 'var') 
    countryName = 'USA';
end
if ~exist('year2Analyze', 'var') 
    year2Analyze = 2014;
end
if ~exist('FePredMethod', 'var') 
    FePredMethod = 'prev';
end
if ~exist('controlMode', 'var') 
    controlMode = 'none';
end

clc;
addpath thirdparty utils

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Анализ собственного движения системы%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yearStart = 2005;
yearBaseInd = year2Analyze - yearStart;
IOModels = dynamicInputOutputModel(countryName);
dynIOModel = IOModels(yearBaseInd);

% Прогноз фондоемкостей для базового года 
% (базовый год == анализируемый год - 1)
dynIOModel.FePred = predictFe(year2Analyze, IOModels , FePredMethod);

showFePrognosisResults(IOModels, dynIOModel, yearStart, year2Analyze)

% Построение матрицы динамической системы 
agregNumb = size(dynIOModel.FePred, 1);
dynIOModel.MPred = zeros(agregNumb, agregNumb);
dynIOModel.MPred(1:end - 1,1:end - 1) = ...
    diag(dynIOModel.rn(1:end - 1) .* ...
    (1 - dynIOModel.rp - dynIOModel.tp(1:end - 1)) .* ...
    (1 - dynIOModel.rw - dynIOModel.rt) ./ dynIOModel.FePred(1:end - 1));
dynIOModel.MPred(end,end) = dynIOModel.rn(end) / dynIOModel.FePred(end);
dynIOModel.D = dynIOModel.MPred * dynIOModel.R;

showSystemPrognosisResults(IOModels, dynIOModel, yearBaseInd, year2Analyze)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Оптимальное управление системой%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(controlMode, 'none')
    return 
end

% Задание ограничений
controlProblem = ...
    setupControlProblem(dynIOModel, controlMode, year2Analyze);

% Поиск оптимального управления
controlProblem.iter = 1;
while norm(controlProblem.vOptNew - controlProblem.vOptPrev) > 1e-10
    controlProblem.vOptPrev = controlProblem.vOptNew;
    lpProblem = reduction2ILPP(controlProblem); % TODO
    controlProblem.vOptNew = linprog(-lpProblem.c, ...
        [-lpProblem.A; lpProblem.A],...
        [-lpProblem.bLower; lpProblem.bUpper], ...
        [], [], lpProblem.dLower, lpProblem.dUpper);
    controlProblem.iter = controlProblem.iter + 1;
end
controlProblem.vOpt = controlProblem.vOptNew;

showControlResults(controlProblem, lpProblem) % TODO

end






