function killrows=outlier(in_t,in_x,out_para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   outlier.m
%
%   Objective : Outlier detection
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
    t=in_t(valrows);     x=in_x(valrows);
    p=polyfit(t,x,pol_deg);
    res=x-polyval(p,t);
    jump=abs(diff(res));
    [maxjump maxrow]=max(jump);
    if maxjump>out_para
%        of=adjacent(t,res);
        of=adjacent(t,x);
        [~,maxofrow]=max(of);
        if abs(res(maxrow+1))>abs(res(maxrow))
            if t(maxrow+1)==t(maxofrow)
                outnum=outnum+1;
                in_x(valrows(maxrow+1))=NaN;
%                 killrows_tmp(outnum,1)=maxrow+1;
                killrows_tmp(outnum,1)=valrows(maxrow+1);   % 2010-10-31
            else
                outdetect=0;
            end
        else 
            if t(maxrow)==t(maxofrow)
                outnum=outnum+1;
                in_x(valrows(maxrow))=NaN;
%                 killrows_tmp(outnum,1)=maxrow;
                killrows_tmp(outnum,1)=valrows(maxrow);     % 2010-10-31
            else
                outdetect=0;
            end
        end
    else
        outdetect=0;
    end
end

killrows=nonzeros(killrows_tmp);




