function dcbsat = igsdcbsat(yyyy,doy,dcbdir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   igsdcbsat.m
%
%   Objective : Get DCBs of satellites from IGS (International GNSS
%               Service) IONEX files
%
%   Input
%       yyyy    : 4-digit year
%       doy     : doy
%       dcbdir  : local direcory where dcb files are archived
%
%   Output
%       dcbsat  : Satellite DCBs
%
%   Version 1.0
%
%   Written by Jung Sungwook, 22. Nov. 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(dcbdir,'dir'), mkdir(dcbdir); end

%% IONEX file download
% ionexfile = sprintf('%s/corg%3.3d0.%2.2di',dcbdir,doy,rem(yyyy,100));
ionexfile = sprintf('%s/igsg%3.3d0.%2.2di',dcbdir,doy,rem(yyyy,100));
if exist(ionexfile,'file')
    fprintf('# A IONEX file for the satellite dcb is ready !!!\n\n');
else
    fprintf('# A IONEX file for the satellite dcb is downloaded !!!\n\n');
    igs_ionex_fetch(yyyy,doy,dcbdir);
    zipfile=sprintf('%s.Z',ionexfile);
    if exist(zipfile,'file')
        eval(sprintf('!gzip -df %s',zipfile))
        fprintf('# A IONEX file for the satellite dcb is ready !!!\n\n');
    else
        fprintf('# ERROR : Cannot Download IONEX file\n');
        return
    end
end

%% DCB
dcbsat_tmp = zeros(50,2);
fid = fopen(ionexfile,'r');
DSC = 0;
while (~feof(fid) && DSC == 0)
    fline = fgetl(fid);
    label=findstr(fline,'START OF AUX DATA');
    if ~isempty(label)
        DSC = 1;
    end
end

count=0;
while (~feof(fid) && DSC == 1)
    fline = fgetl(fid);
    label=findstr(fline,'PRN / BIAS / RMS');
    if isempty(label)
        DSC = 0;
    else
        if strcmp(fline(4),'G') || strcmp(fline(4),' ')
            count = count + 1;
            dcbsat_tmp(count,:) = [str2num(fline(5:6)) -str2num(fline(8:16))];
        end
    end
end
fclose(fid);
dcbsat = dcbsat_tmp(1:count,:);

function igs_ionex_fetch(yyyy,doy,dcbdir)

yy=rem(yyyy,100);
igshost = 'cddis.gsfc.nasa.gov';
iondir = sprintf('gps/products/ionex/%4d/%3.3d',yyyy,doy);
% ionfile = sprintf('jprg%3.3d0.%2.2di.Z',doy,yy);
ionfile = sprintf('igsg%3.3d0.%2.2di.Z',doy,yy);

fcon=ftp(igshost); binary(fcon);
cd(fcon,iondir);
mget(fcon,ionfile,dcbdir);
close(fcon);