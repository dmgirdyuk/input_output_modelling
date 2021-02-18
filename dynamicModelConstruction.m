function inputOutputModel =...
    dynamicModelConstruction(modelNext, modelCurr)
% Вычисление коэффициента фондоемкости и составной части марицы 
% динамической системы 
       
n = size(modelNext.I,1); 
Fe = ones(n,1);
M = zeros(n,n);

Fe(1:end - 1,1) = modelNext.Cp ./ ...
    (modelNext.I(1:end - 1) - modelCurr.I(1:end - 1));       
Fe(n,1) = sum(modelNext.Cp) / (modelNext.I(end) - modelCurr.I(end));


M(1:end - 1,1:end - 1) = diag(modelCurr.rn(1:end - 1) .* ...
    (1 - modelCurr.rp - modelCurr.tp(1:end - 1)) .* ...
    (1 - modelCurr.rw - modelCurr.rt) ./ Fe(1:end - 1));
M(end,end) = modelCurr.rn(end) / Fe(end);

inputOutputModel = modelCurr;
inputOutputModel.Fe = Fe;
inputOutputModel.M = M;

end
