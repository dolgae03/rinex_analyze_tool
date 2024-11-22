clear all;
clc

%%
yyyy = 2020;
yy=rem(yyyy,100);
doy_start =61;%%%%%%%%%%%%%%%%%txan doy82, 122 확인하기  
doy_end = 130;
% stalist=cell({'txan'});
stalist=cell({'nyil' 'nylp' 'txau' 'rod1' 'txan'})


[homedir, mfile, ext]=fileparts(mfilename('fullpath'));
addpath(homedir);
sourcedir=sprintf('%s/sources',homedir);
addpath(sourcedir);
%% RINEX file download

% for staid=stalist
%     staid=char(staid);
%     rnx_gather(yyyy,doy_start,doy_end,staid, homedir)
% end
% cd(homedir)

% %% Multipath 생성
tintv=5;
smoothingTime=100;
for staid=stalist
    staid=char(staid)
    for doy = doy_start:doy_end
        generate_multipath_main_mc(yyyy,doy,staid,homedir,tintv,smoothingTime)
    end
end
cd(homedir)

%% mat file 저장
for staid=stalist
    staid=char(staid);
    for doy = doy_start:doy_end
        meanwid=round(smoothingTime/tintv);
        make_matfile(homedir, yyyy, doy, staid, yy,meanwid);
    end
end



