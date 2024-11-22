function of = adjacent(x,y)

%
%   Objective : compute Outlier Factor (OF)
%
%   Input
%       x : vector of x-components
%       y : vector of y-components
%
%   Ouput
%       of : outlier factor
%
%   Reference
%   Kou, Y., Lu, C.-T., and Chen, D., ¡°Spatial Weighted Outlier Detection,¡±
%   Proceedings of the 2006 SIAM International Conference on Data Mining, 
%   Bethesda, MD, Apr. 20-22, 2006, pp. 614-618.
%
%   Versioin 1.0
%
%   Programmed by Jung Sungwook, 23 Oct. 2010
%

of=zeros(size(x));
nbrbound=300*3;

for n=1:size(x,1)
    % Get Adjacent Points
    row=find(abs(x-x(n))<=nbrbound & x~=x(n));
    nbrx=x(row);    nbry=y(row);
    % Weight Calculation
    wgtavg=0;
    for m=1:size(row,1)
        difference=abs(y(n)-nbry(m));
        wgt=getweight(nbrx,x(n),nbrx(m));
        wgtavg=wgtavg+wgt*difference;
%         wgtavg=wgtavg+nbry(m)*wgt;
    end
    of(n)=wgtavg;
%     of(n)=y(n)-wgtavg;
end
% mu=mean(of);    sig=std(of);
% of=abs(of-mu)/sig;


function weight=getweight(x,xi,xj)
invdist=0;
for n=1:size(x,1)
    invdist=invdist+1/abs(x(n)-xi);
end
weight=(1/abs(xi-xj))/invdist;