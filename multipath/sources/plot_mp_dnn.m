


prn = 5;
yyyy = 2019;
yy = rem(yyyy,100);
staid = 'nyil';
doy_start = 55;
doy_end = 85;

for doy = doy_start:doy_end
    
%     doy = 83
%         homedir = 'D:\HDD_D\minchan\Code\multipath_generation_code_PNT';
%         wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy-1);
%         mp_name = sprintf('%s/%s%3.3d0%2.2d',wkdir,staid,doy-1,yy);
%         load(mp_name)
%         data_last = data_dc;
        
        wkdir = sprintf('%s/iacs/%4d/%3.3d',homedir,yyyy,doy);
        mp_name = sprintf('%s/%s%3.3d0%2.2d',wkdir,staid,doy,yy);
        outfile = sprintf('%s/%s%3.3d0%2.2d_prn5',wkdir,staid,doy,yy);
        load(mp_name)
    
%         row_last = find(data_last(:,2) == prn);
%         temp_last = data_last(row_last,:);
        row = find(data_dc(:,2) == prn);
        temp = data_dc(row,:);
        
        if doy == 55
        mp_sample = temp(100:2499,:);
%         continue
        end
        
        [~, offset_row]=min(abs(temp(1:500,3) - mp_sample(1,3)));
        
        temp(1:offset_row-1,:) = [];
        temp(2401:end,:) = [];
        
        
        save(outfile,'temp');
        
%         f2=figure;
%         subplot(3,1,1)
%         plot(mp_sample(:,9),'.')
%         hold on
%         plot(temp(:,9),'r.')
% %         xlim([temp(1,1)/3600, temp(end,1)/3600])
%         ylim([-3 3])
%         subplot(3,1,2)
% %         plot(mp_diff,'.')
%         
%         subplot(3,1,3)
%         plot(mp_sample(:,3),'.')
%         hold on
%         plot(temp(:,3),'r.')
% %         xlim([temp(1,1)/3600, temp(end,1)/3600])
%         
%         

%         
    
    
end