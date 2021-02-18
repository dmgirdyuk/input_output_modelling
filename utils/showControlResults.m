function showControlResults(uProb, lpProb)
% Подстановка полученного оптимального управления в нелинейную систему

N = uProb.N;
n = uProb.n;
r = uProb.r;
rn = uProb.rn;
rp = uProb.rp;
tp = uProb.tp;
rw = uProb.rw;
rt = uProb.rt;
FePred = uProb.FePred;

IFinal = uProb.I;

for j = 0 : N - 1
    MClosed = zeros(n);
    RClosed = uProb.R;
    switch uProb.controlMode
        case 'rw'
            MClosed(1:end - 1, 1:end - 1) = ...
                diag(rn(1:end - 1) .* ...
                    (1 - rp - tp(1:end - 1)) .* ...
                    (1 - rw - rt - ...
                        uProb.vOpt(j * r + 1:j * r + n - 1)) ./ ...
                    FePred(1:end - 1));
        case 'tp'
            MClosed(1:end - 1, 1:end - 1) = ...
                diag(rn(1:end - 1) .* ...
                    (1 - rp - tp(1:end - 1) - ...
                        uProb.vOpt(j * r + 1:j * r + n - 1)) .* ...
                    (1 - rw - rt) ./ ...
                    FePred(1:end - 1));
            RClosed(end,end) = uProb.R(end,end) + ...
                uProb.vOpt((j + 1) * r);
    end 
    MClosed(end,end) = rn(end) / FePred(end);
    DClosed = MClosed * RClosed;
    IFinal = expm(DClosed / N) * IFinal;
end

fprintf('======================\n')
fprintf('Оптимальное управление\n')
fprintf('======================\n')
switch uProb.controlMode
    case 'rw'
        optControl = [rw, reshape(uProb.vOpt, r, N)] * 100
    case 'tp'
        optControl = [tp, reshape(uProb.vOpt, r, N)] * 100
end
fprintf('Выпуски в %i году:', uProb.t0)
vpa(uProb.I)

fprintf('Прогноз на %i год:', uProb.t1)
sobstvDvijSyst = vpa(expm(uProb.D) * uProb.I)
fprintf('Относительная разница (%%) к %i году', uProb.t0)
vpa((sobstvDvijSyst - uProb.I) ./ uProb.I * 100)

fprintf(join(['Количество итераций для нахождения \n', ...
    'оптимального управления:']))
uProb.iter

fprintf(join(['Прогноз выпусков при оптимальном управлении: \n', ...
    '(для линеаризованной системы)'])) 
IFinalLinear = vpa(sobstvDvijSyst + lpProb.A * uProb.vOpt)
fprintf('Относительная разница (%%) к %i году', uProb.t0)
vpa((IFinalLinear - uProb.I) ./ uProb.I * 100) 

fprintf(join(['Прогноз выпусков при оптимальном управлении: \n', ... 
    '(билинейная система замкнута оптимальным управлением для \n', ...
    'линеаризованной системы)'])) 
vpa(IFinal)
fprintf(join(['Относительная (%%) разница отклонения \n', ...
    'финальных значений выпусков при оптимальном управлении \n', ...
    'линеаризованной системы по отношению к билинейной системе, \n', ...
    'замкнутой тем же оптимальным управлением']))
vpa((IFinal - IFinalLinear) ./ IFinalLinear * 100) 

end