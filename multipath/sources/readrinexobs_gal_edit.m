function [obsdate,epochs,types,rcvData,rcvSvid,gps_sec]=readrinexobs_gal_edit(rnxfile)


fpid = fopen(rnxfile,'r');
types = {};
count = 0;
num = 0;
type_case = 0;
while ~feof(fpid)
    fline = fgetl(fpid);
    esize = size(fline,2);
    if esize >= 79
        if strcmp(fline(71:79),'OBS TYPES') && (strcmp(fline(1:1),'G') || strcmp(fline(1:1),' '));
            type_temp = fline(8:58);
            str_type = strread(type_temp, '%s', 'delimiter', ' ');
            types = {types{:},str_type{:}};
        end
    end
    
    if strcmp(fline(1:1),'>');
        num = num +1;
        utctime = [str2num(fline(3:6)),str2num(fline(8:9)),str2num(fline(11:12)),str2num(fline(14:15)),str2num(fline(17:18)),str2num(fline(20:29))];
        [~,sec] = utc2gps(utctime,0);
        [t_sod(1,1) t_sod(1,2) t_sod(1,3)] = cal2doysec(utctime(1),utctime(2),utctime(3),utctime(4),utctime(5),utctime(6));
    end
    if num == 1;
        obsdate = utctime;
    end
    
    esize = size(fline,2);
    if strcmp(fline(1:1),'G') && num >=1;
        if type_case == 0
            C1=1;  C2=4; L1=2; L2 = 5; S1 = 3; S2 = 6; C7 = 7; L7 = 8; S7 = 9 ;
            for m=1:size(types,2)
                switch types{m}
                    case 'C1C'
                        C1 = m;
                    case 'C2W'
                        C2 = m;
                    case 'L1C'
                        L1 = m;
                    case 'L2W'
                        L2 = m;
                    case 'S1C'
                        S1 = m;
                    case 'S2W'
                        S2 = m;
                    case 'D1C'
                        D1 = m;
                    case 'D2W'
                        D2 = m;
                    case 'C7Q'
                        C7 = m;
                    case 'L7Q'
                        L7 = m;
                    case 'S7Q'
                        S7 = m;
                end
            end
        
        data = nan(12,1);
        
        count = count+1;
        prn = str2num(fline(2:3));
        if esize>=65 && ~isempty(str2num(fline(5:17)))
            data(1,1) = str2num(fline(5:17));       % C1
            data(2,1) = str2num(fline(20:33));      % L1
            data(3,1) = str2num(fline(40:49));      % D1
            data(4,1)  = str2num(fline(59:65));     % S1
        end
        
        
        if esize>=129 && ~isempty(str2num(fline(67:81)))
            data(5,1)  = str2num(fline(67:81));
            data(6,1) = str2num(fline(85:97));
            data(7,1) = str2num(fline(102:113));      % D1
            data(8,1)  = str2num(fline(123:129));
        end
        
        
        if esize>=193 && ~isempty(str2num(fline(131:145)))
            data(9,1) = str2num(fline(131:145));
            data(10,1)= str2num(fline(149:161));
            data(12,1)  = str2num(fline(187:193));
        end

%         rcvData(count,:) = [C1C L1C S1C C5Q L5Q S5Q];
        rcvData(count,:) = [data(C1,1) data(L1,1) data(D1,1) data(S1,1) data(C2,1) data(L2,1) data(D2,1) data(S2,1)];
        rcvSvid(count,:) = prn;
        epochs(count,:) = t_sod(1,3);
        gps_sec(count,:) = sec;
        
    end
    
    
end


end

