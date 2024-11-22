function idx_el=elevationIdx(bins,testinput);
el=testinput(:,1);
idx_el=cell(1,length(bins)-1);
for k=2:length(bins)
    rows=find(el>=bins(k-1) & el<bins(k));
    idx_el{k-1}=rows;
end
end
