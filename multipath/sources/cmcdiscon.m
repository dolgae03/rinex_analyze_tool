function eff=cmcdiscon(iphi,icmc,el1,el2,thtime,width,ellim,nodiscon,th_res) %#eml

eml.varsize('iphi','icmc','el1','el2',[8000 2],[1 1]);
assert(isa(iphi,'double') && size(iphi,1)<=8000);
assert(isa(icmc,'double') && size(iphi,1)<=8000);
assert(isa(el1,'double') && size(iphi,1)<=8000);
assert(isa(el2,'double') && size(iphi,1)<=8000);

% width = 1.5*3600;  % time interval to search for discontinuties on residual between 
%               % I_phi slope and I_CMC slope, in hours
% ellim = 15;   % elevation limit to search for discontinuties on residual between 
%               % I_phi slope and I_CMC slope, in degrees
% nodiscon = 5; % number of the discontinuty
% th_res = 150;

[t_el row1 row2] = intersect(el1(:,1),el2(:,1),'rows');
el = zeros(size(t_el,1),2);
el(:,1) = t_el;
el(:,2) = (el1(row1,2)+el2(row2,2))/2;
effrow = abs(el(:,1)-thtime)<width;

% No interest in low elevation data
if ~isempty(find(el(effrow,2)<ellim,1))
    eff=1;
    return
end

% Discontinuity check
[t_res row1 row2] = intersect(iphi(:,1),icmc(:,1),'rows');
res = zeros(size(t_res,1),2);
res(:,1) = t_res;
res(:,2) = abs(iphi(row1,2)-icmc(row2,2));
effrow = abs(res(:,1)-thtime)<width;
if sum(res(effrow,2)>th_res)>nodiscon
    eff=0;
else
    eff=1;
end