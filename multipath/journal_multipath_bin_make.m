hiddenlay = [20 20];
yyyy = 2019;
yy=rem(yyyy,100);
interval=5;

bins=[10:10:90];
numbins=length(bins)-1;
mulOrig_bins=cell(1,numbins);
mulDNN_bins=cell(1,numbins);
mulDaily_bins=cell(1,numbins);
for doy=doylist
    for prn=1:32;
        
        if (doy==130 & prn==21) | (doy==134 & prn==14)
            continue
        end
        % 데이터 불러오기
        modeldir = sprintf('%s/model file/%4d/%s/PRN%2.2d',homedir,yyyy,staid,prn);
        laystr = num2str(hiddenlay,'%2.2d');
        modelname = sprintf('%s/DNN%sprn%2.2d_layer%s_testDOY%3.3d.mat',modeldir,staid,prn,laystr,doy);
        if ~exist(modelname, 'file');  continue;   end;
        load(modelname); 
        yest = [yesttime yestinput yestoutput];
        tod = [testtime testinput testoutput];
        [mulOrig testinput mulYest yestinput timee] = findidx2(yest, tod, interval);
        [mulDNN, errorDNN, sigDNN, sigOrig, rateDNN,idx_DNN] = DNN_TestPlot(DNN, testinput, mulOrig);
        mulYest = mulYest(idx_DNN);
        mulOrig = mulOrig(idx_DNN);
        testinput = testinput(idx_DNN,:);
        
        % 데이터 확인
        mulOrig;
        errorDNN;        
        errorYest=mulOrig-mulYest;
        testinput;
            
        % elevation 별로 나누기
        idx_el=elevationIdx(bins,testinput);
        for k=1:numbins
            mulOrig_bins{k}=[mulOrig_bins{k}; mulOrig(idx_el{k})];
            mulDNN_bins{k}=[mulDNN_bins{k}; errorDNN(idx_el{k})];
            mulDaily_bins{k}=[mulDaily_bins{k}; errorYest(idx_el{k})];
%             if sum(abs(errorDNN(idx_el{k}))>1.5) > 3
%                 figure()
%                 plot(mulOrig,'k')
%                 hold on
%                 plot(mulDNN,'r')
%                 plot(mulYest,'b')
%                 ss=sprintf('DOY: %d, PRN: %d',doy, prn);
%                 grid on
%                 title(ss)
%             end
        end
    end
end

numsample=length(mulOrig_bins{numbins});
for k=1:numbins
    ds=length(mulOrig_bins{k});
    tmp=[1:1:ds];
    tmp2=randsample(tmp,numsample);
    mulOrig_bins{k}=mulOrig_bins{k}(tmp2);
    mulDaily_bins{k}=mulDaily_bins{k}(tmp2);;
    mulDNN_bins{k}=mulDNN_bins{k}(tmp2);;
end


