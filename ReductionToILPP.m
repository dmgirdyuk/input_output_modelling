function [c,A,bl,bu,dl,du] = ReductionToILPP(c0,H,gl,gu,ul,uu,...
                                             A0,t0,x0,tn,N,...
                                             rn,rp,tp,rw,rt,Fe,...
                                             v_opt,Aa,mode)
% Iteration of the algorithm which finds the optimal control for 
% bilinear control system by solving the sequence of linear problems, 
% using the solution (optimal control for linear problem) from 
% previos step.

% c0 -- coefficients of the functional
% H -- matrix of the main constraints of the system variables
% gl and gu -- lower and upper bounds for main constraints
% ul and uu -- lower and upper bounds for the control variables
% A0 -- matrix of the system
% t0 and tn -- bounds of the time interval
% x0 -- initial state of the system
% N -- amount of discretization steps
% rn, rp, tp, rw, rt, Fe -- parameters of the system
% v_opt -- optimal control from the previous iteration
% Aa -- matrix A of the model
% mode -- which parameter is used for control
% 1 -- rw or rt, 2 -- tp(1:end - 1)
              
% Size of the control vector
r = size(ul,2);
% Number of sectors
n = size(x0,1);
% Descritization step
step = (tn - t0) / N;

% Fundamental matrix at the final moment of time
Yn = expm(A0 * (tn - t0));
% Fundamental matrix of the adjoint system at the initial time
Z0 = eye(size(A0));

P = [];
Q = [];
Vl = [];
Vu = [];

% Calculation of the coefficients of the objective function and 
% main constraints matrix of ILPP. The Simpson formula is used 
% for numerical integration.
X_opt_b = x0;
AaInit = Aa;

for j = 0 : N - 1
    YnZaT = Yn * expm(-A0' * (j * step))';
    YnZcT = Yn * expm(-A0' * ((j + 0.5) * step))';
    YnZbT = Yn * expm(-A0' * ((j + 1) * step))';
    
    M = zeros(size(x0,1));
    % The use of optimal control v_opt for linearized problem 
    % obtained from the previous step
    switch mode
            case 1
                for i = 1 : n - 1
                    M(i,i) = rn(i) * (1 - rp(i) - tp(i)) *...
                      (1 - rw(i) - rt(i) - v_opt(j * r + i)) /...
                      Fe(i);
                end
            case 2
                for i = 1 : n - 1
                    M(i,i) = rn(i) *...
                      (1 - rp(i) - tp(i) - v_opt(j * r + i)) *...
                      (1 - rw(i) - rt(i)) /...
                      Fe(i);   
                end

%                 Aa(r,1:end - 1) = AaInit(r,1:end - 1) -...
%                                   v_opt(j * r + 1:j * r + n - 1)';
                Aa(end,end) = AaInit(end,end) +...
                              v_opt((j + 1) * r);
        end
    
    M(end,end) = rn(end) / Fe(end);

    X_opt_a = X_opt_b;
    X_opt_c = expm(M * Aa * (0.5 * step)) * X_opt_b;
    X_opt_b = expm(M * Aa * step) * X_opt_b;

    switch mode
        case 1
            beta = -rn(1:end - 1) .* (1 - rp - tp(1:end - 1)) ./...
                   Fe(1:end - 1);
            B0a = [];
            B0c = [];
            B0b = [];
            for k = 1 : n - 1
                B0a = [B0a,...
                       diag([zeros(1,k - 1),...
                             beta(k),...
                             zeros(1,n - k)]) * Aa * X_opt_a
                      ];
                B0c = [B0c,...
                       diag([zeros(1,k - 1),...
                             beta(k),...
                             zeros(1,n - k)]) * Aa * X_opt_c
                       ];
                B0b = [B0b,...
                       diag([zeros(1,k - 1),...
                             beta(k),...
                             zeros(1,n - k)]) * Aa * X_opt_b
                      ];
            end
            B0a = [B0a, zeros(n,1)];
            B0c = [B0c, zeros(n,1)];
            B0b = [B0b, zeros(n,1)];
        case 2
            gamma = -rn(1:end - 1) .*...
                     (1 - rw - rt) ./ Fe(1:end - 1);
            B0a = [];
            B0c = [];
            B0b = [];
            for k = 1 : n - 1
                Aa1 = zeros(n);
%                 Aa1(n,k) = -rn(end) / Fe(end);
                B0a = [B0a,...
                       (diag([zeros(1,k - 1),...
                             gamma(k),...
                             zeros(1,n - k)]) * Aa + Aa1) * X_opt_a
                      ];
                B0c = [B0c,...
                       (diag([zeros(1,k - 1),...
                             gamma(k),...
                             zeros(1,n - k)]) * Aa + Aa1) * X_opt_c
                       ];
                B0b = [B0b,...
                       (diag([zeros(1,k - 1),...
                             gamma(k),...
                             zeros(1,n - k)]) * Aa + Aa1) * X_opt_b
                      ];
            end
            Aa1 = zeros(n);
            Aa1(n,n) = rn(end) / Fe(end);
            B0a = [B0a, Aa1 * X_opt_a];
            B0c = [B0c, Aa1 * X_opt_c];
            B0b = [B0b, Aa1 * X_opt_b];
    end
    
    for k = 1 : r
        Pa = c0 * YnZaT * B0a(:,k);
        Pc = c0 * YnZcT * B0c(:,k);
        Pb = c0 * YnZbT * B0b(:,k);
        P(j * r + k) = step / 6 * (Pa + 4 * Pc + Pb);
        Qa = H * YnZaT * B0a(:,k);
        Qc = H * YnZcT * B0c(:,k);
        Qb = H * YnZbT * B0b(:,k);
        Q(:,j * r + k) = step / 6 * (Qa + 4 * Qc + Qb);
        Vl(j * r + k) = ul(k);
        Vu(j * r + k) = uu(k);       
    end
end

% Calculation of boundaries for basic constraints
g0l = gl - H * Yn * Z0' * x0;
g0u = gu - H * Yn * Z0' * x0;

c = double(P);
A = double(Q);
bl = double(g0l);
bu = double(g0u);
dl = Vl';
du = Vu';

end

