stalist=cell({'nylp' 'txau' 'rod1' 'txan'})
doy_start=113;
doy_end=143;

homedir='E:\PNT2019_journal\journal_multipath_code3\iacs\»õ Æú´õ\2019';
tarhome='E:\PNT2019_journal\journal_multipath_code3';
for staid=stalist
    staid=char(staid);
    for doy=doy_start:doy_end
        mfilename=sprintf('%s/%3.3d/%s%3.3d019.mat',homedir,doy,staid,doy);
        if ~exist(mfilename,'file');
            continue
        end
        
        tardir=sprintf('%s/iacs/2019/%3.3d',tarhome,doy);
        if ~exist(tardir,'dir')
            mkdir(tardir);
        end
        
        newmfilename=sprintf('%s/%s%3.3d19.mat',tardir,staid,doy);
        
        load(mfilename);
        tmp=data_dc(:,[1 2 3 4 10 9 6 7]);
        data_dc=tmp;
        save(newmfilename,'data_dc');
    end
end


