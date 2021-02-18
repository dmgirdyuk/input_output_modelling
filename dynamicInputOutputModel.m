function inputOutputModels = ...
    dynamicInputOutputModel(countryName, aggregNumb, aggregSect)
% ���������� ������������ ������ �������������� ������� (���).
%
% ������� ���������:
%     countryName -- �������������� ������, ����������� ������;
%     agregNumb -- ����� �� ��������� [2, 37], ���������� �������������� 
%       �������� (36 �������� � �� + ���);
%     aggregSect -- ������-������� ����������� 1x37, ���������� ��������
%       ��������� ��������� �������������� ������� � �������������� ������;
%     
% �������� ���������:
%     inputOutputModels -- ������ ��������, ���������� ����������� ������ 
%       ���;

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
                aggregSect = [ones(N_SECT, 1); 2];
            case 4
                aggregSect = [ones(20, 1); 2 * ones(11, 1); ...
                    3 * ones(5, 1); 4];
            otherwise
                aggregSect = linspace(1, N_SECT + 1, N_SECT + 1)';       
        end
end

yearFirst = 2005;
yearLast = 2015;
yearDiff = yearLast - yearFirst + 1;

% C��������, ���������� �������������� ����������� ������
% �������������� �������
% ������-������� �������� ��������� 
inputOutputModel.I = zeros(aggregNumb, 1); 
% ������� ����������� ������
inputOutputModel.R = zeros(aggregNumb, aggregNumb); 
% ������-������� ���������� (��� ���������� ������������ ������)
inputOutputModel.Cp = zeros(aggregNumb, 1); 
% ���������� �������������� ���������: 
% ������-������� � ������ �������������� ����������� � ��������
inputOutputModel.rp = zeros(aggregNumb - 1, 1);
% ������-������� � ������ ���������� ����� � ����������� ����������
inputOutputModel.rw = zeros(aggregNumb - 1, 1);
% ������-������� � ������ ������ ������� �� ������������ � �����������
% ����������
inputOutputModel.rt = zeros(aggregNumb - 1, 1);
% ������-������� � ������ ������ ������� �� ��������� � ��������
inputOutputModel.tp = zeros(aggregNumb, 1);
% ������-������� � ������ ���������� � ������ ������� ��������
inputOutputModel.rn = zeros(aggregNumb, 1);

% ������-������� ������������� ��������
inputOutputModel.Fe = zeros(aggregNumb,1);
% ��������������� ������� ������������ ������
inputOutputModel.M = zeros(aggregNumb,aggregNumb);

% ������ ����� ��������
inputOutputModels = repmat(inputOutputModel, 1, yearDiff);

% ��������� ������ �� ��� ��� countryName 
gdp = readtable(fullfile('data', 'GDP', 'gdp.csv'));
countryRealGdp = ...
    table2array(gdp(strcmp(gdp.countryColumn, countryName), 3))';
% � �� OECD ��� ��������� ����� ���� ������� ���, �� ��� ���������� �� ���. 
% � ����� ������ ������������� �� ��������� ���, ����������� �� ������ 
% ������ ��� �� ������������
if size(countryRealGdp) < yearDiff
    countryRealGdp = zeros(yearDiff);
end

% ��������� ������ ��������, ���������� ���������� ��� ����������
% ����������� ������ ���
for yearInd = 1:yearDiff
    inputOutputModel = ...
        staticModelConstruction(yearFirst - 1 + yearInd, countryName, ...
            aggregNumb, countryRealGdp(yearInd), aggregSect, true);     
    inputOutputModels(yearInd) = inputOutputModel;
end

% ��������� ��������� (����� ��������� ��� ���������� ����) 
% �������������� ������������ � ��������� ������������ �������
for yearInd = 1:yearDiff - 1
    inputOutputModel = ...
        dynamicModelConstruction(inputOutputModels(yearInd + 1), ...
            inputOutputModels(yearInd));
    inputOutputModels(yearInd) = inputOutputModel;
end

end
