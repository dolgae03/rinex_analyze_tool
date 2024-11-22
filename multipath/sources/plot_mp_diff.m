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
        if doy == 55
           continue 
        end
               
        
        homedir = 'I:\HDD_D\minchan\Code\multipath_generation_code_PNT';
        wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy-1);
        mp_name = sprintf('%s/%s%3.3d0%2.2d',wkdir,staid,doy-1,yy);
        load(mp_name)
        data_last = data_dc;
        
        homedir = 'I:\HDD_D\minchan\Code\multipath_generation_code_PNT';
        wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy);
        mp_name = sprintf('%s/%s%3.3d0%2.2d',wkdir,staid,doy,yy);
        load(mp_name)
        
        
        fname_mp=sprintf('%2.2d_%3.3d_mp',prn,doy);
        
        row_last = find(data_last(:,2) == prn);
        temp_last = data_last(row_last,:);
        row = find(data_dc(:,2) == prn);
        temp = data_dc(row,:);
        
        
        [~, offset_row]=min(abs(temp(1:500,3) - temp_last(100,3)));
        
        offset = 100-offset_row;
        
        if offset >= 1
           temp_last(1:offset,:) = [];
            
        elseif offset < 0
            
            temp(1:offset,:) = [];
        end
        
        if size(temp,1) > size(temp_last,1)
        
        mp_diff = abs(temp(1:size(temp_last,1),9) - temp_last(:,9));
        lang = size(temp_last,1);
        else
        mp_diff = abs(temp(:,9) - temp_last(1:size(temp,1),9));
          lang = size(temp,1);  
        end
        
        
        f2=figure;
        subplot(3,1,1)
        plot(temp(1:lang,9),'.')
        hold on
        plot(temp_last(1:lang,9),'r.')
%         xlim([temp(1,1)/3600, temp(end,1)/3600])
        ylim([-3 3])
        subplot(3,1,2)
        plot(mp_diff,'.')
        
        subplot(3,1,3)
        plot(temp(1:lang,3),'.')
        hold on
        plot(temp_last(1:lang,3),'r.')
%         xlim([temp(1,1)/3600, temp(end,1)/3600])
        
        
        
        
        
%         hgsave(f2,fname_mp);
        print(f2,'-djpeg',[fname_mp '.jpg'])
        close all
    end
    
end