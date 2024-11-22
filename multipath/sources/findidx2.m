function [todmul todinput yestmul yestinput timee]=findidx2(yest, todd, interval);

    yest2=nan(length([0:interval:86400]),5);
    yest2(:,1)=0:interval:86400;
    idx=ismember(yest2(:,1), yest(:,1));
    yest2(idx,2:5)=yest(:,2:5);
    
    
    todd2=nan(length([0:interval:86400]),5);
    todd2(:,1)=0:interval:86400;
    idx=ismember(todd2(:,1), todd(:,1));
    todd2(idx,2:5)=todd(:,2:5);
    
    diff_val=[];
    for k=1:100
        tmp=yest2(k+1:end,2)-todd2(1:end-k,2);
        diff_val(k)=nansum(tmp.^2);
    end
    
    [~, idx]=min(diff_val);
    yest3=yest2(idx+1:end,2:5);
    todd3=todd2(1:end-idx,2:5);
    
    timee=yest2(idx+1:end,1);
    tmp=yest3(:,1)-todd3(:,1);
    idx=~isnan(tmp);
    yestmul = yest3(idx,4);
    yestinput = yest3(idx,1:3);
    todmul = todd3(idx,4);
    todinput = todd3(idx,1:3);
    timee=timee(idx);
    

end