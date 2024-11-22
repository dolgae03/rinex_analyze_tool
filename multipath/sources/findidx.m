function [todmul todinput yestmul yestinput fflag]=findidx(data1, data2)

if data1(1,1)<data2(1,1)
    smallelev=data1;
    largeelev=data2;
    flag=1;
else
    smallelev=data2;
    largeelev=data1;
    flag=2;
end
fflag=0;
if (data1(1,1)-data1(2,1))<0  % elevation이 증가하는 상황
    targetelev=largeelev(1,1);
    idx_elev=find(abs(smallelev(1:100,1)-targetelev)<0.03);
    if isempty(idx_elev);
        fflag=1; 
        return; 
    end
    idx=idx_elev(1);
    idxdata=smallelev;
    rawdata=largeelev;
    
else    % elevation이 감소하는 상황
    targetelev=smallelev(1,1);
    idx_elev=find(abs(largeelev(1:100,1)-targetelev)<0.03);
    if isempty(idx_elev);
        fflag=1; 
        return; 
    end
    idx=idx_elev(1);
    idxdata=largeelev;
    rawdata=smallelev;
    if flag==1
        flag=2;
    else
        flag=1;
    end
end

len=min([length(idxdata(idx:end,1)) length(rawdata(1:end,1))]);

if flag==1
    yestmul=idxdata(idx:idx+len-1,4);
    yestinput=idxdata(idx:idx+len-1,1:3);
    todmul=rawdata(1:len,4);
    todinput=rawdata(1:len,1:3);
else
    todmul=idxdata(idx:idx+len-1,4);
    todinput=idxdata(idx:idx+len-1,1:3);
    yestmul=rawdata(1:len,4);
    yestinput=rawdata(1:len,1:3);
end


    
    
