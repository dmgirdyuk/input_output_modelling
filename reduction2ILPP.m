function lpProblem = reduction2ILPP(uProb)
% Сведение билинейной интервальной задачи оптимального управления к задаче
% линейного программирования. Подробнее во 2 параграфе 4 главы книги

N = uProb.N;
n = uProb.n;
r = uProb.r;
rn = uProb.rn;
rp = uProb.rp;
tp = uProb.tp;
rw = uProb.rw;
rt = uProb.rt;
FePred = uProb.FePred;

% Шаг дискретизации
step = (uProb.t1 - uProb.t0) / N;

% Фундаментальная матрица в конченый момент времени
Yn = expm(uProb.D * (uProb.t1 - uProb.t0));
% Фундаментальная матрица сопряженной системы в начальный момент времени
Z0 = eye(size(uProb.D));

P = [];
Q = [];
vLower = [];
vUpper = [];

% Вычисление коэффициентов целевой функции и матрицы основных ограничений
% интервальной задачи линейного программирования
% Для численного интегрирования используется формула Симпсона
xOptB = uProb.x0;

for j = 0 : N - 1   
    MClosed = zeros(n);
    RClosed = uProb.R;
    % Подстановка текущего оптимального решения для линеаризованной
    % системы, полученное на предыдущем шаге
    switch uProb.controlMode
        case 'rw'
            MClosed(1:end - 1, 1:end - 1) = ...
                diag(rn(1:end - 1) .* ...
                    (1 - rp - tp(1:end - 1)) .* ...
                    (1 - rw - rt - ...
                        uProb.vOptPrev(j * r + 1:j * r + n - 1)) ./ ...
                    FePred(1:end - 1));
        case 'tp'
            MClosed(1:end - 1, 1:end - 1) = ...
                diag(rn(1:end - 1) .* ...
                    (1 - rp - tp(1:end - 1) - ...
                        uProb.vOptPrev(j * r + 1:j * r + n - 1)) .* ...
                    (1 - rw - rt) ./ ...
                    FePred(1:end - 1));
            RClosed(end,end) = uProb.R(end,end) + ...
                uProb.vOptPrev((j + 1) * r);
    end
    MClosed(end,end) = rn(end) / FePred(end);
    xOptA = xOptB;
    xOptC = expm(MClosed * RClosed * (0.5 * step)) * xOptB;
    xOptB = expm(MClosed * RClosed * step) * xOptB;

    switch uProb.controlMode
        case 'rw'
            beta = rn(1:end - 1) .* (1 - rp - tp(1:end - 1)) ./ ...
                   FePred(1:end - 1);
            B0A = [];
            B0C = [];
            B0B = [];
            for k = 1 : n - 1
                B0A = [B0A,...
                       diag([zeros(1, k - 1),...
                             -beta(k),...
                             zeros(1, n - k)]) * RClosed * xOptA];
                B0C = [B0C,...
                       diag([zeros(1, k - 1),...
                             -beta(k),...
                             zeros(1, n - k)]) * RClosed * xOptC];
                B0B = [B0B,...
                       diag([zeros(1, k - 1),...
                             -beta(k),...
                             zeros(1, n - k)]) * RClosed * xOptB];
            end
        case 'tp'
            gamma = rn(1:end - 1) .*...
                     (1 - rw - rt) ./ FePred(1:end - 1);
            B0A = [];
            B0C = [];
            B0B = [];
            for k = 1 : n - 1
                B0A = [B0A,...
                       diag([zeros(1, k - 1),...
                             -gamma(k),...
                             zeros(1, n - k)]) * RClosed * xOptA];
                B0C = [B0C,...
                       diag([zeros(1, k - 1),...
                             -gamma(k),...
                             zeros(1, n - k)]) * RClosed * xOptC];
                B0B = [B0B,...
                       diag([zeros(1, k - 1),...
                             -gamma(k),...
                             zeros(1, n - k)]) * RClosed * xOptB];
            end
            RLast = zeros(n);
            RLast(n,n) = rn(end) / FePred(end);
            B0A = [B0A, RLast * xOptA];
            B0C = [B0C, RLast * xOptC];
            B0B = [B0B, RLast * xOptB];
    end
    
    YnZaT = Yn * expm(-uProb.D' * (j * step))';  
    YnZcT = Yn * expm(-uProb.D' * ((j + 0.5) * step))'; 
    YnZbT = Yn * expm(-uProb.D' * ((j + 1) * step))'; 
    
    for k = 1 : r
        Pa = uProb.c * YnZaT * B0A(:, k);
        Pc = uProb.c * YnZcT * B0C(:, k);
        Pb = uProb.c * YnZbT * B0B(:, k);
        P(j * r + k) = step / 6 * (Pa + 4 * Pc + Pb);
        Qa = uProb.H * YnZaT * B0A(:, k);
        Qc = uProb.H * YnZcT * B0C(:, k);
        Qb = uProb.H * YnZbT * B0B(:, k);
        Q(:,j * r + k) = step / 6 * (Qa + 4 * Qc + Qb);
        vLower(j * r + k) = uProb.uLower(k);
        vUpper(j * r + k) = uProb.uUpper(k);       
    end
end

% Вычисление границ на основные ограничения
g0Lower = uProb.ILastLower - uProb.H * Yn * Z0' * uProb.x0;
g0Upper = uProb.ILastUpper - uProb.H * Yn * Z0' * uProb.x0;

lpProblem.c = double(P);
lpProblem.A = double(Q);
lpProblem.bLower = double(g0Lower);
lpProblem.bUpper = double(g0Upper);
lpProblem.dLower = vLower';
lpProblem.dUpper = vUpper';

end
