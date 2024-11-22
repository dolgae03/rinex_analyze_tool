%
%   dst_get.m
%
%   Objective
%   Get the daily maximum of Dst value for a given day.
%   
%   INPUT
%   yyyy     : 4-digit year
%   doy      : Day of year
%
%   OUTPUT
%   dst      : Dst value for a given day
%   dst_type : Dst type in string format. There are 3 kinds of type.
%               1) Final
%               2) Provisional
%               3) Quicklook (Real-time)
%
%   Version 1.0
%   
%   Edited by Sungwook Jung, 16 June, 2011
%
%   Note
%   The program uses Dst values provided by World Data Center 
%   for Geomagnetism, Kyoto (http://wdc.kugi.kyoto-u.ac.jp/)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dst dst_type] = dst_get(yyyy,doy)

% Conversion from doy to calendric form
[yr mm dd] = doy2cal(yyyy,doy);
syr = num2str(yr);
smm = num2str(mm);
if mm < 10, smm = sprintf('0%s',smm); end

% hostname of Kyoto Univ.
url = 'http://wdc.kugi.kyoto-u.ac.jp';

n = 0;
while n<3   % dst has 3 kinds of types
    n=n+1;
    % Choose directory accroding to the data type
    switch n
        case 1
            type_dir = 'dst_final';
        case 2
            type_dir = 'dst_provisional';
        case 3
            type_dir = 'dst_realtime';
    end
    
    % the data page in URL
    urlhost = [url '/' type_dir '/' syr smm '/index.html'];
    % data download
    datafile = sprintf('%s%s_%s',syr,smm,type_dir);
    if exist(datafile,'file'), delete(datafile), end
    [~, status] = urlwrite(urlhost,datafile);
    if status, break, end   % When the proper data type is found, 
                            % terminate the loop.
end

% If no dst is returned, terminate the function
if ~status
    error('No Dst on %4d-%3.3d\n',yyyy,doy);
end

% Read a datafile
dstarray = kyoto_dst_read(datafile);

% Effective data only
dstarray = dstarray(dstarray(:,1)==dd & dstarray(:,3)~=9999,:);

% If no effective data, terminate the function
if isempty(dstarray)
    delete(datafile);
    error('No Dst on %4d-%3.3d\n',yyyy,doy);
end

% Return
[~, index] = max(abs(dstarray(:,3)));
dst = dstarray(index,3);
dst_type = type_dir(5:end);
delete(datafile);