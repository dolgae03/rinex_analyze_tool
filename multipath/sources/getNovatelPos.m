function [epochs pos]=getNovatelPos(filename)
epochs=[];
pos=[];

[fid, message]=fopen(filename, 'rt');
if fid==-1
    fprintf(2, 'Error open %s\', filename)
    return
end

while 1
    tline=fgetl(fid);
    
    if tline==-1
        break
    end
    
    
    if strcmp(tline(1:9),'#BESTPOSA')
       epochs=[epochs; str2num(tline(41:46))];
       pos=[pos; str2num(tline(91:104)), str2num(tline(106:120)), str2num(tline(122:128))];
           
    else
        continue
    end
    
end
    