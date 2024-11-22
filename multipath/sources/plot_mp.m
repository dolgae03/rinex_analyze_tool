close all
yyyy = 2019;
yy = rem(yyyy,100);

doy_start = 55;
doy_end = 85;
staid = 'nyil';


prnlist = [2,5,10,14,15,20,26,31,32];

for n=1:9
    prn = prnlist(n);
    for doy = doy_start:doy_end
        
        doy
        prn
        
        homedir = 'I:\HDD_D\minchan\Code\multipath_generation_code_PNT';
        wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy);
        mp_name = sprintf('%s/%s%3.3d0%2.2d',wkdir,staid,doy,yy);
        load(mp_name)
        
        fname_mp=sprintf('%2.2d_%3.3d_mp',prn,doy);
        
        
        row = find(data_dc(:,2) == prn);
        temp = data_dc(row,:);
        
        f2=figure;
        subplot(2,1,1)
        plot(temp(:,1)/3600,temp(:,9),'.')
        xlim([temp(1,1)/3600, temp(end,1)/3600])
        ylim([-3 3])
        subplot(2,1,2)
        plot(temp(:,1)/3600,temp(:,3),'.')
        
        xlim([temp(1,1)/3600, temp(end,1)/3600])
        
%         hgsave(f2,fname_mp);
        print(f2,'-djpeg',[fname_mp '.jpg'])
        close all
    end
    
end