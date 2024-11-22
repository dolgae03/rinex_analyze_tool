function Multipath_Code = mpCalculator(t, csFlag, C1, L1, iphi, lambda1)

acrrow = find(csFlag>=10);
if isempty(acrrow);
    arc_num=1;
else
    arc_num = size(acrrow,1);
end

Multipath_Code =  zeros(size(t,1),1);

for arc=1:arc_num
    if arc_num==1 || arc==arc_num
        stop_t  = t(end);
    else
        stop_t  = t(acrrow(arc+1)-1);
    end
    if arc_num==1 || arc==1
        start_t = t(1);
    else
        start_t = t(acrrow(arc));
    end
    valrows = find(t>=start_t & t<=stop_t & ~isnan(L1));

    Multipath_Code(valrows,1) = C1(valrows,1)-L1(valrows,1)*lambda1 - 2*iphi(valrows); %MP1

    Multipath_Code(valrows,1) = Multipath_Code(valrows,1)-mean(Multipath_Code(valrows,1), "omitnan"); %MP1
end
