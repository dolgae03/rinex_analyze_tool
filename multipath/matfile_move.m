doy_start=113;
doy_end=143;

stalist=cell({'nylp' 'txau' 'rod1' 'txan'})
himedir_file='E:\PNT2019_journal\journal_multipath_code3\iacs\»õ Æú´õ';
[homedir, mfile, ext]=fileparts(mfilename('fullpath'));


for staid=stalist
    staid=char(staid)
    for doy = doy_start:doy_end
        filename=sprintf('%s/2019/%3.3d/%s%3.3d19.mat',himedir_file,doy,staid,doy);
        tardir=sprintf('%s/iacs/2019/%3.3d',himedir_file,doy);
        copy filename tardir
    end
end

