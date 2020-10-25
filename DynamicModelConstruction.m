function [Fe, Ma] =...
    DynamicModelConstruction(XaNext,XaPrev,rp,rw,rt,tp,rn)
       
n = size(XaNext,1); 
Fe = ones(n,1);
Ma = zeros(n,n);

Fe(1:end - 1,1) = (1 - rp - tp(1:end - 1)) .* (1 - rw - rt) .* rn(1:end - 1) ./...
    log(XaNext(1:end - 1) ./ XaPrev(1:end - 1));    
Fe(n,1) = rn(end) / log(XaNext(end) / XaPrev(end));

Ma(1:end - 1,1:end - 1) = diag(rn(1:end - 1) .* (1 - rp - tp(1:end - 1)) .*...
                                (1 - rw - rt) ./ Fe(1:end - 1));
Ma(end,end) = rn(end) / Fe(end);


% function [Fe, Ma] =...
%     DynamicModelConstruction1(XaNext,XaPrev,IaNext,...
%                              rp,rw,rt,tp,rn)
%        
% n = size(XaNext,1); 
% Fe = ones(n,1);
% Ma = zeros(n,n);
% 
% Fe(1:end - 1,1) = IaNext ./ (XaNext(1:end - 1) - XaPrev(1:end - 1));       
% Fe(n,1) = sum(IaNext) / (XaNext(end) - XaPrev(end));
% 
% Ma(1:end - 1,1:end - 1) = diag(rn(1:end - 1) .* (1 - rp - tp(1:end - 1)) .*...
%                                 (1 - rw - rt) ./ Fe(1:end - 1));
% Ma(end,end) = rn(end) / Fe(end);






 