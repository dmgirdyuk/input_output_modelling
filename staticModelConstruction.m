function inputOutputModel = staticModelConstruction(year, countryName, ...
    aggregNumb, countryRealGdp, aggregSect, showStats)
% ���������� ����������� ������ ��� �� ������ ������� �� OECD
% 
% ������� ���������:
%     year -- ��� �� ��������� [2005, 2015];
%     countryName -- �������������� ������, ����������� ������;
%     aggregNumb -- ���������� �������������� ��������;
%     countryRealGdp -- ��� countryName;
%     aggregSect -- ������-������� ����������� 1x37, ���������� ��������
%       ��������� ��������� �������������� ������� � �������������� ������;
%     showStats -- �������� �������� ��� �� �������� ��� � ���������� 
%       ���������� ����������� ������;
% 
% �������� ��������:
%     inputOutputModel -- ���������, ���������� ���������� �����������
%       ������ ���;

% ���������� �������� ��������� � �������� OECD
nSect = 36;

if ~exist('year', 'var')
    year = 2005;
end
if ~exist('countryName', 'var') 
    countryName = 'USA';
end
if ~exist('aggregNumb', 'var') 
    aggregNumb = 4;
end
if ~exist('aggregSect', 'var') 
        % �������� ��������� (� 4 �������) ������������� �������� 
        % ������������ � ����� 'data/sectAggreg.xlsx'
        switch aggregNumb
            case 2
                aggregSect = [ones(nSect, 1); 2];
            case 4
                aggregSect = [ones(20, 1); 2 * ones(11, 1); ...
                    3 * ones(5, 1); 4];
            otherwise
                aggregSect = linspace(1, nSect + 1, nSect + 1)';       
        end
end
if ~exist('countryRealGdp', 'var') 
    countryRealGdp = 0;
end
if ~exist('showStats', 'var') 
    showStats = true;
end

% ��������� ���������� �� ���������� ������ ���������� � �����
% 'data/data_sources.txt'
tDomImp = readtable(fullfile('data', 'NATIODOMIMP', join([countryName, ...
    num2str(year), 'dom.csv'], '')));
tValueAdded = readtable(fullfile('data', 'VAROW', 'VAROW_ascii.csv'), ...
    'Delimiter', '|', 'ReadVariableName', false);

% ������� ������������� ������ Pd (������ ������)
Pd = table2array(tDomImp(1:nSect, 2:nSect + 1));

% ������� ������������� ������ Zm (�� ������)
Pm = table2array(tDomImp(nSect + 1:2 * nSect, 2:nSect + 1));

% ������� ������ ������� �� ������������� ��������� 
% Tproducts(���������� ��� � ������ ������ ��������������)
TProducts = table2array(tDomImp(2 * nSect + 1:2 * nSect + 2, ...
    2:nSect + 1));

% ������� ������ ������� �� �������� ��������� TFinProducts
TFinProducts = table2array(tDomImp(2 * nSect + 1:2 * nSect + 2, ...
    nSect + 2:nSect + 9));

% ������ ������ ����� W
W = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'LABR'), ...
    6))';

% ������ ������ ������� �� ������������� ������������ Tproduction
TProduction = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'OTXS'), ...
    6))';

% ������ �������� ������������� ��������� � ���������� ������ GOPS
Gops = table2array(...
    tValueAdded(strcmp(tValueAdded.Var2, countryName) & ...
    tValueAdded.Var3 == year & strcmp(tValueAdded.Var4, 'GOPS'), ...
    6))';

% ������� ��������� ����������� �������� �������� C
C = table2array(tDomImp(1:nSect, ...
    nSect + 2:nSect + 3));

% ������ ������ ����������� �� �������� ����������� G
G = table2array(tDomImp(1:nSect, ...
    nSect + 4));

% ������� ���������� Cp
Cp = table2array(tDomImp(1:nSect, ...
    nSect + 5:nSect + 6));

% ������� �������� Ex
Ex = table2array(tDomImp(1:nSect, ...
    nSect + 8:nSect + 9));

% ������ ������� I
I = table2array(tDomImp(2 * nSect + 5, 2:nSect + 1));

% �������
I = (I - TProducts(1, :))';

% ������ ����������� ���������
VA = W + TProduction + Gops;

% ����������
Cp = sum(Cp,2);

% ���
GDP = sum(VA) + sum(TProducts(2, :)) + sum(TFinProducts(2, :));

% ������ ��������� ������
Y = sum(C, 2) + G + sum(Cp, 2) + ...
    sum(Ex, 2) - sum(Pm, 2) - TProducts(1, :)';

% ���������� ����������� ������� ��������������� �������������
n = size(I, 1);
for j = 1 : n
    if I(j) ~= 0
        R(:, j) = (Pd(:, j) + Pm(:, j)) / I(j);
        VAr(j) = (VA(j) + TProducts(2, j)) / I(j);
    else
        R(:, j) = 0;
        VAr(j) = 0;
    end
end

% ������� ������� I -- ������� OECD �� �������� ���������
% �����������������, ������� ���������� ��������������� ������ Y ��
% �������� ���������� (���� � ��������������)
err = I - R * I - Y;
Y = Y + err;

I = [I; GDP];
R = [R, Y / GDP; VAr, sum(TFinProducts(2, :)) / GDP];

% ����������� ���������
if showStats
    fprintf('%.0f ��� \n', vpa(year))
    fprintf('�������� �������� ��� ������: %.4f \n', vpa(countryRealGdp))
    fprintf('��� ������ �� ������ ������ ���: %.4f \n', vpa(GDP))
    fprintf('������������� ������ ���: %.2f%% \n', ...
        vpa((countryRealGdp - GDP) / countryRealGdp * 100))
    fprintf('norm(I - RI)): %.4f \n\n', ...
        vpa(norm(I - R * I)))
end

% �������������
Ia = zeros(aggregNumb, 1);
Ra = zeros(aggregNumb, aggregNumb);
Cpa = zeros(aggregNumb - 1, 1);

if aggregNumb ~= size(I,1)
    [Ia, Ra] = aggregation(I, R, aggregSect);
end

% ���������� ����������� �������������� ���������
rp = zeros(aggregNumb - 1, 1);
rw = zeros(aggregNumb - 1, 1);
rt = zeros(aggregNumb - 1, 1);
tp = zeros(aggregNumb, 1); 
rn = zeros(aggregNumb, 1);

for k = 1 : aggregNumb - 1
    tmpind = find(aggregSect == k)';
    rp(k) = 1 - Ra(aggregNumb,k);
    rw(k) = sum(W(tmpind)) / sum(VA(tmpind));
    rt(k) = sum(TProduction(tmpind)) / sum(VA(tmpind));
    tp(k) = sum(TProducts(2,tmpind)) / Ia(k);
    Cpa(k) = sum(Cp(tmpind));
end
tp(aggregNumb) = Ra(aggregNumb, aggregNumb); 

rn(1:end - 1, 1) = Cpa ./ ...
    ((1 - rp - tp(1:end - 1)) .* (1 - rw - rt) .* Ia(1:end - 1));
rn(end, 1) = sum(Cpa) / (Ia(end));

% �������� ������������� ���������, ���������� ���������� � 
% ����������� ������
inputOutputModel.I = Ia;
inputOutputModel.R = Ra;
inputOutputModel.Cp = Cpa;
inputOutputModel.rp = rp;
inputOutputModel.rw = rw;
inputOutputModel.rt = rt;
inputOutputModel.tp = tp;
inputOutputModel.rn = rn;

inputOutputModel.Fe = zeros(aggregNumb, 1);
inputOutputModel.M = zeros(aggregNumb, aggregNumb);

fprintf('norm(I - RI)): %.4f \n\n', ...
    vpa(norm(inputOutputModel.I - inputOutputModel.R * inputOutputModel.I)))

end
