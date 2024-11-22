function eff=cmcdatachk(icmcraw,thtime) %#eml

eml.varsize('icmcraw',[8000 2],[1 1]);
assert(isa(icmcraw,'double') && size(icmcraw,1)<=8000);

cmcrow= icmcraw(:,1)==thtime & ~isnan(icmcraw(:,2));

if any(cmcrow)
    eff=1;
else
    eff=0;
end
