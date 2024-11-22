function rnx_gather(yyyy,doy_start,doy_end,staid,homedir)


gzipfile = [homedir '\utility\gzip124xN\gzip.exe'];
rnxhome = [homedir '\rinex'];
brdchome = [homedir '\brdc'];
addpath(homedir);
for doy = doy_start:doy_end
    corshost = 'geodesy.noaa.gov';
    % igshost = 'www.ngs.noaa.gov';
    if doy == doy_start
        fcon = ftp(corshost);          binary(fcon);
    end
    
    yy = rem(yyyy,100);
    brdcdir = sprintf('/cors/rinex/%4d/%3.3d',yyyy,doy);
    brdcfile1 = sprintf('brdc%3.3d0.%2.2d%s.Z',doy,yy,'n');
    brdcfile2 = sprintf('brdc%3.3d0.%2.2d%s.gz',doy,yy,'n');
    tar_dir = sprintf('%s/%4d',brdchome,yyyy);
    if ~exist(tar_dir,'dir'), mkdir(tar_dir); end
    copyfile(gzipfile,tar_dir)
    
    
    efile =   sprintf('brdc%3.3d0.%2.2d%s',doy,yy,'n');
    if exist(efile,'file')
        fprintf('%s brdc file Ready !!!\n',efile);
    else
        filelist = dir(fcon,brdcdir);
        if size(filelist,1)
            for m=1:size(filelist,1)
                if strcmp(filelist(m).name,brdcfile1)
                    cd(fcon,brdcdir);
                    mget(fcon,brdcfile1,tar_dir);
                    valid=1;
                    brdcfile=brdcfile1;
                    break
                elseif strcmp(filelist(m).name,brdcfile2)
                    cd(fcon,brdcdir);
                    mget(fcon,brdcfile2,tar_dir);
                    valid=1;
                    brdcfile=brdcfile2;
                    break
                end
            end
        end
        
        if valid
            eval(['!gzip -df ' tar_dir '/' brdcfile]);
            fprintf (' BRDC file, %s Downloaded !!!\n',brdcfile);
        else
            fprintf(' WARNING : No BRDC file, %s !!!\n',brdcfile);
        end
        
    end
    
    mp_rnxdir = sprintf('%s/%4d/%3.3d',rnxhome,yyyy,doy);
    if ~exist(mp_rnxdir,'dir'), mkdir(mp_rnxdir); end
    cd(mp_rnxdir);
    copyfile(gzipfile,mp_rnxdir)
    
    rnxdir = sprintf('/cors/rinex/%4d/%3.3d/%s',yyyy,doy,staid);
    rnxfile = sprintf('%s%3.3d0.%2.2do.gz',staid,doy,yy);
    ofile = sprintf('%s%3.3d0.%2.2do',staid,doy,yy);
    if exist(ofile,'file')
        fprintf('%s RINEX file Ready !!!\n',ofile);
    else
        try
            cd(fcon,rnxdir);
            fprintf('%s RINEX file down !!!\n',ofile);
            mget(fcon,rnxfile,mp_rnxdir);
            eval(sprintf('!gzip -df %s',rnxfile))
            
        catch
            fprintf('%s RINEX file not exist !!!\n',ofile);
        end
        
    end
    if doy==doy_end
        close(fcon)
    end
    
end

end


