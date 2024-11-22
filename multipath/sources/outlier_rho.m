function killrows = outlier_rho(in_t,in_x,out_para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   outlier_rho.m
%
%   Objective : Outlier detection for code measurement
%
%   Input
%       in_t     : time
%       in_x     : measurement or observation
%       out_para : parameter for outlier detection
%   
%   Output
%       killrows : rows where the measurement are outliers.
%
%   Version 1.0
%
%   Edited by Jung Sungwook, 23 Oct. 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


outdetect=1;
pol_deg=int8((in_t(end)-in_t(1))/3600)+4;

outnum=0;
killrows_tmp=zeros(1000000,1);
while outdetect
    valrows=find(~isnan(in_x));
    if pol_deg>=size(valrows,1)
        killrows = valrows;
        return
    end
    t=in_t(valrows);    x=in_x(valrows);
    p=polyfit(t,x,pol_deg);
    res=x-polyval(p,t);       %% Previous Version
    jump=abs(diff(res));
%     res=abs(x-polyval(p,t));    %% Current Version(2010-9-2)
%     jump=zeros(size(res,1)-1,1);
%     for n=1:size(jump,1)
%         jump(n)=res(n)+res(n+1);
%     end
    [maxjump maxrow]=max(jump);
    if maxjump>out_para
        outnum=outnum+1;
        if abs(res(maxrow+1))>abs(res(maxrow))
            in_x(valrows(maxrow+1))=NaN;
%             killrows_tmp(outnum,1)=maxrow+1;
            killrows_tmp(outnum,1)=valrows(maxrow+1);
        else
            in_x(valrows(maxrow))=NaN;
%             killrows_tmp(outnum,1)=maxrow;
            killrows_tmp(outnum,1)=valrows(maxrow);
        end
    else
        outdetect=0;
    end
end

killrows=nonzeros(killrows_tmp);