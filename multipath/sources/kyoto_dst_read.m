%   
%   kyoto_dst_read.m
%
%   Objective
%   Read a Dst file of Kyoto Univ. in a http format
%   and return a new variable
%
%   INPUT
%   dstfile     : Kyoto Dst file
%
%   OUTPUT
%   dst         : Output variable
%                   1st column : day of month
%                   2nd column : hour of day
%                   3rd column : Dst
%
%   Versioin : 0.1
%   
%   Edited by Jung Sung-Wook (jungsw@kaist.ac.kr)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dst = kyoto_dst_read(dstfile)

fdstid = fopen(dstfile,'r');
EOH = 0;
% pass through html code lines
while (~feof(fdstid) && EOH == 0)
    fline = fgetl(fdstid);
    label = findstr(fline,'DAY');
    if ~isempty(label), EOH = 1; end
end

count = 0;
while ~feof(fdstid)
    fline = fgetl(fdstid);
    if ~isempty(fline)
        if strcmp(fline(1:2),'<!'), break, end
        day = str2num(fline(1:2));
        hr = 0;
        while hr < 24
            count = count + 1;
            if hr<8
                scol = 4 + hr * 4;
            elseif hr>=8 && hr<16
                scol = 37 + (hr - 8) * 4;
            else
                scol = 70 + (hr - 16) * 4;
            end
            value = str2num(fline(scol:scol+3));
            dst(count,1) = day;
            dst(count,2) = hr;
            dst(count,3) = value;
            hr = hr+1;
        end
    end
end
fclose(fdstid);