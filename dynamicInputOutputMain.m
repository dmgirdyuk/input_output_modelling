function [inputOutputModels, dynamicModel] = ...
    dynamicInputOutputMain(countryName, aggregNumb, aggregSect)
% ���������� ������������ ������ �������������� ������� (���).
%
%     ������� ���������:
%     countryName -- �������������� ������, ����������� ������;
%     agregNumb -- ����� �� ��������� [2, 37], ���������� �������������� 
%     �������� (36 �������� � �� + ���);
%     aggregSect -- ������-������� ����������� 1x37, ���������� ��������
%     ��������� ��������� �������������� ������� � �������������� ������.
%     
%     �������� ���������:
%     inputOutputModels -- ������ ��������, ���������� ����������� ������ 
%     ��� � ����������: TODO
%     dynamicModel -- ���������, ���������� ������������ ������ ��� �
%     ����������: TODO

% ��������� ������������� ������� ����������
if nargin < 3
    if exist('aggregNumb','file') 
        % �������� ��������� (� 4 �������) ������������� �������� 
        % ������������ � ����� sectAggreg.xlsx
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
    if nargin < 2
        aggregNumb = 4;
        aggregSect = [ones(20, 1); 2 * ones(11, 1); 3 * ones(5, 1); 4];
        if nargin < 1
            countryName = "DEU";
        end    
    end
end

addpath('thirdparty')

yearFirst = 2005;
yearLast = 2015;

yearDiff = yearLast - yearFirst + 1;

% C��������, ���������� �������������� ����������� ������
% �������������� �������
% ������-������� �������� ��������� 
inputOutputModel.X = zeros(aggregNumb, 1); 
% ������� ����������� ������
inputOutputModel.A = zeros(aggregNumb, aggregNumb); 
% ������-������� ���������� (��� ���������� ������������ ������)
inputOutputModel.I = zeros(aggregNumb, 1); 
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

% ������ ����� ��������
inputOutputModels = repmat(inputOutputModel, 1, yearDiff);

% ��������� ������ �� ��� ��� countryName �� ������   
% ������ misc/downloadGdpData.m ��������� � ������ ������ �� ���
gdp = readtable(fullfile('data', 'GDP', 'gdp.csv'));
countryRealGdp = ...
    table2array(gdp(strcmp(gdp.countryColumn, countryName), 3))';
% � �� OECD ��� ��������� ����� ���� ������� ���, �� ��� ���������� �� ���. 
% � ����� ������ ������������� �� ��������� ���, ����������� �� ������ 
% ������ ��� �� ������������
if size(countryRealGdp) < yearDiff
    countryRealGdp = zeros(yearDiff);
end

for yearInd = 1:yearDiff
    inputOutputModel = ...
        staticModelConstruction(yearFirst - 1 + yearInd, countryName, ...
        aggregNumb, countryRealGdp(yearInd), aggregSect); 
    break
    
    inputOutputModels(yearInd) = inputOutputModel;
end

end
        





%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % ��������� ��������� (����� ��������� ��� ������� ����) 
%         % �������������� ������������ � ��������� ������������ �������

% % ������� M ��� ���������� ������ ������������ ������
% Fe = zeros(agregN,year_diff - 1);
% Ma = zeros(agregN,agregN,year_diff);
% FeN = zeros(agregN,year_diff - 1);
% MaN = zeros(agregN,agregN,year_diff);


%         if yearInd ~= 1
%             [Fe(:,yearInd - 1), Ma(:,:,yearInd - 1)] =...
%                 DynamicModelConstruction(Xa(:,yearInd),Xa(:,yearInd - 1),...
%                               rp(:,yearInd - 1),rw(:,yearInd - 1),rt(:,yearInd - 1),...
%                               tp(:,yearInd - 1),rn(:,yearInd - 1));
%             [FeN(:,yearInd - 1), MaN(:,:,yearInd - 1)] =...
%                 DynamicModelConstruction1(Xa(:,yearInd),Xa(:,yearInd - 1),...
%                               Ia(:,yearInd - 1),...
%                               rp(:,yearInd - 1),rw(:,yearInd - 1),rt(:,yearInd - 1),...
%                               tp(:,yearInd - 1),rn(:,yearInd - 1));
%         end
%     end 
% 
%     for k = 6 : 14
%         k + 2000
%         XaNext = expm(MaN(:,:,k) * Aa(:,:,k)) * Xa(:,k);
%         vpa(Xa(:,k))
%         vpa(Xa(:,k + 1))
%         vpa(XaNext)
%         rel_diff_next_forecast = ((Xa(:,k + 1) - XaNext) ./ Xa(:,k + 1) * 100)
%     end

% end
