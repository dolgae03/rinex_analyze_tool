function make_matfile(homedir, yyyy, doy, staid, yy,meanwid);

multfile = sprintf('%s/iacs/%4d/%3.3d/%s%3.3d%2.2d.mat',homedir,yyyy,doy,staid,doy,yy);
if exist(multfile, 'file')
    load(multfile);
    prnlist = unique(data_dc(:,2))';
    for prn = prnlist
        prnrow = find(data_dc(:,2)==prn);
        prndata = data_dc(prnrow, [1 3 4 5 6]);
        prndata(:,4) = movmean(prndata(:,4), meanwid);
        tar_dir = sprintf('%s/mat file/%4d/%s/PRN%2.2d', homedir, yyyy, staid, prn);
        if ~exist(tar_dir, 'dir'), mkdir(tar_dir); end
        [rows, columns] = find(isnan(prndata));
        row_nan=unique(rows);
        prndata(row_nan,:)=[];
        outfilename = sprintf('%s/%sPRN%2.2dDOY%3.3d.mat', tar_dir, staid, prn, doy);
        save(outfilename, 'prndata');
    end
else
    fprintf('%s  %3.3d No file \n', staid, doy)
end
end
