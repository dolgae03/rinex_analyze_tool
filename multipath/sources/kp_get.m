%
%   kp_get.m
%
%   Objective 
%   Get the daily maximum of Kp for a given day
%
%   INPUT
%   yyyy     : 4-digit year
%   doy      : Day of year
%
%   OUTPUT
%   kp       : kp value for a given day
%   kp_type  : kp type in string format. There are 2 kinds of type.
%               1) Final (NGDC)
%               2) Prediction (SWPC)
%
%   Version 1.0
%
%   Edited by Sungwook Jung, 16 June, 2011
%
%   Note
%   The program uses Kp values provided by the following:
%       1. National Geographysical Data Center (NGDC) for the final
%           ftp://ftp.ngdc.noaa.gov
%       2. Space Weather Prediction Center (SWPC) for the prediction
%           ftp://ftp.swpc.noaa.gov
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [kp kp_type] = kp_get(yyyy,doy)

% Conversion from doy to calendric form
[yr mm dd] = doy2cal(yyyy,doy);
syr = num2str(yr);
smm = num2str(mm);
if mm < 10, smm = sprintf('0%s',smm); end

% 1. Final Kp
ngdchost = 'ftp.ngdc.noaa.gov';
ngdcdir  = '/STP/GEOMAGNETIC_DATA/INDICES/KP_AP';
fcon = ftp(ngdchost);
ascii(fcon);
cd(fcon,ngdcdir);
rawfile = syr;  % the file including Kp information
filecont = dir(fcon,rawfile);
if size(filecont,1)     % only if there exists the file (final Kp)
    if exist(rawfile,'file'), delete(rawfile); end
    mget(fcon,rawfile);
    kparray = ngdc_kp_read(rawfile);
    kparray=kparray(kparray(:,1)==mm & kparray(:,2)==dd,:);
    if ~isempty(kparray)  % If there exists the final data of Kp on a given day
        kp = max(kparray(:,4));
        kp_type = 'final';
        delete(rawfile);
        close(fcon);
        return
    end
end
delete(rawfile);
close(fcon);


% 2. Predicted Kp
% If there is no final Kp, we investigate the predicted Kp.
swpchost = 'ftp.swpc.noaa.gov';
swpcdir  = '/pub/indices/old_indices';
fcon = ftp(swpchost);
ascii(fcon);
cd(fcon,swpcdir);
order_q = ceil(mm/3);  % how many quaters in one year
rawfile = sprintf('%4dQ%d_DGD.txt',yr,order_q);  % the file including Kp information
filecont = dir(fcon,rawfile);
if size(filecont,1)     % only if there exists the file (predicted Kp)
    mget(fcon,rawfile);
    kparray = swpc_kp_read(rawfile,'quar');
    kparray=kparray(kparray(:,1)==mm & kparray(:,2)==dd,:);
    if ~isempty(kparray)  % If there exists the final data of Kp on a given day
        kp = max(kparray(:,4));
        kp_type = 'predicted';
        delete(rawfile);
        close(fcon);
        return
    else
        delete(rawfile);
        close(fcon);
        error('No Kp on %4d-%3.3d\n',yyyy,doy);
    end
else
    close(fcon);
    error('No Kp on %4d-%3.3d\n',yyyy,doy);
end

%% Read a Kp file of NGDC
function kp = ngdc_kp_read(kpfile)
% kp    1st column : month
%       2nd        : day
%       3rd        : hour
%       4th        : Kp value

fkpid = fopen(kpfile,'r');
count = 0;
while ~feof(fkpid)
    fline = fgetl(fkpid);
    if isempty(fline), continue, end
    mm = str2num(fline(3:4)); dd = str2num(fline(5:6));
    hh = 0;
    while hh < 24
        count = count + 1;
        value = str2num(fline(13+hh/3*2:13+(hh/3+1)*2-1))/10;
        kp(count,1) = mm;   kp(count,2) = dd; %#ok<*AGROW>
        kp(count,3) = hh;   kp(count,4) = value;
        hh = hh + 3;
    end
end
fclose(fkpid);

%% Read a Kp file of SWPC
function kp = swpc_kp_read(kpfile,type)
% kp    1st column : month
%       2nd        : day
%       3rd        : hour
%       4th        : Kp value

fkpid = fopen(kpfile,'r');
% header reading
EOH = 0;
while (~feof(fkpid) && EOH == 0)
    fline = fgetl(fkpid);
    switch type
        case 'last'
            label = findstr(fline,'-----------');
        case 'quar'
            label = findstr(fline,'Date');
    end
    if ~isempty(label), EOH = 1; end
end

% value reading
count = 0;
while ~feof(fkpid)
    fline = fgetl(fkpid);
    mm = str2num(fline(6:7));   dd = str2num(fline(9:10));
    hh = 0;
    while hh < 24
        count = count + 1;
        value = str2num(fline(64+2*hh/3:65+2*hh/3));
        if value~=-1
            kp(count,1) = mm;   kp(count,2) = dd; %#ok<*AGROW>
            kp(count,3) = hh;   kp(count,4) = value;
            hh = hh + 3;
        else
            fclose(fkpid);
            return
        end
    end
end
fclose(fkpid);