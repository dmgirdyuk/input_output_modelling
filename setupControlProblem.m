function controlProblem = ...
    setupControlProblem(dynIOModel, controlMode, year2Analyze)

controlProblem = dynIOModel;
N = 4; % число отрезков управления
n = size(dynIOModel.I, 1);

switch controlMode
    case 'rw' 
        % На примере USA 2014
        controlProblem.ILastLower = dynIOModel.I;
        controlProblem.ILastUpper(1, 1) = dynIOModel.I(1) * 1.028;
        controlProblem.ILastUpper(2, 1) = dynIOModel.I(2) * 1.040;
        controlProblem.ILastUpper(3, 1) = dynIOModel.I(3) * 1.018;
        controlProblem.ILastUpper(4, 1) = dynIOModel.I(4) * 1.033;
        controlProblem.r = n - 1;
        controlProblem.uLower = -0.1 * dynIOModel.rw;
        controlProblem.uUpper = 0.1 * dynIOModel.rw;
        controlProblem.vOptPrev = ones((n - 1) * N, 1);
        controlProblem.vOptNew = zeros((n - 1) * N, 1);
    case 'tp'
        % На примере IND 2014
        controlProblem.ILastLower = dynIOModel.I;
        controlProblem.ILastUpper(1, 1) = dynIOModel.I(1) * 1.024;
        controlProblem.ILastUpper(2, 1) = dynIOModel.I(2) * 1.033;
        controlProblem.ILastUpper(3, 1) = dynIOModel.I(3) * 1.0235;
        controlProblem.ILastUpper(4, 1) = dynIOModel.I(4) * 1.033;
        controlProblem.r = n;
        controlProblem.uLower = -dynIOModel.tp;
        controlProblem.uUpper = dynIOModel.tp;
        controlProblem.vOptPrev = ones(n * N, 1);
        controlProblem.vOptNew = zeros(n * N, 1);
end

% функционал качества c * I -> max
% controlProblem.c = [ones(1, n - 1), 0];
controlProblem.c = ones(1, n);
% Матрица интервальных ограничений на фазовые переменные систем
controlProblem.H = diag(ones(1, n));
controlProblem.t0 = year2Analyze - 1;
controlProblem.x0 = dynIOModel.I;
controlProblem.t1 = year2Analyze;
controlProblem.n = n;
controlProblem.N = N;
controlProblem.controlMode = controlMode;

end