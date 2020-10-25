function [Ia,Ra] = aggregation(Iw,Rw,aggregateIndustriesNumber)
% ��������� �������������.
%
% ����������� ��� �� �����
% �������� �. �., ������� �. �., �������� �. �. ����������� � ������������
% ������ ���������������� ���������: ������� �������. ��� : ������������
% ��� ��������� �.�., 2017.
% 
% ������� ���������: ������ Iw � ������� Rw ����������� ������, ������
% aggregateIndustriesNumber, �������� ��� ������� ������� ��������� �����
% ��������������� �������, � ������� �� ������ �������. ���� ������ ���-
% ��� ��������� ��� ����� ����� �� ���������� [1, m], ������� ����� ��-
% ���������, ���� ��������� �������� ��������� � ���� � ��� �� ��������-
% ������ ������. ����� m � ���������� ����� �������������� ��������.
% 
% �������� ���������: ������ Ia � ������� Ra �������������� �����������
% ������.

% ���������� �������������� ��������
m = max(aggregateIndustriesNumber);

% ���������� ���� cell, � ������ � ������� i ���������� ������ ��������,
% ������� ������ � i-� ������������� ������.
aggregateIndustry = cell(1,m);

Ia = zeros(m,1);
Ra = zeros(m);
industryAmount = 0;
for i = 1:m
    aggregateIndustry{i} = find(aggregateIndustriesNumber == i);
    Ia(i,1) = sum(Iw(aggregateIndustry{i},1));
    industryAmount = industryAmount + length(aggregateIndustry{i});
end
if industryAmount ~= size(aggregateIndustriesNumber,1)
    errordlg("������������ ������ ������� aggregateIndustriesNumber");
end
for i = 1:m
    for j = 1:m
        R1 = Rw(aggregateIndustry{i}, aggregateIndustry{j});
        I1 = Iw(aggregateIndustry{j});
        Ra(i,j) = sum(R1 * I1) / Ia(j,1);
    end
end
