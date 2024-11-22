function dcb = dcbestvarsta(t,iphi,prnlist,dcbsat,elset,mask,lon,dt,hI)%#eml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   dcbestvarsta.m
%
%   Objective
%   estimate IFB for a receiver
%
%   Input
%       t       : time in second of day (n X 1)
%       iphi    : iono. delay (n X 1)
%       prnlist : list of PRN (n X 1)
%       dcbsat  : DCBs of satellites (m X 1)
%       elset   : elevation (n X 1)
%       mask    : cut-off angle of elevation for DCB estimation
%       lon     : longitude of the station
%       dt      : time interval
%       hI      : mean ionospheric height, in km
%
%   Output
%       dcb     : Rcv. DCB in nanosecond
%
%  Original by Mr. Wook
%  Modified by Dr. John Wallis, Nov 2010
%  Modified by Mr. Kim, April 2012: To processe 1sec data; 
%  Modified by Sungwook Jung, April 2012: ionospheric height
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eml.varsize('iphi', [40000 1]);
eml.varsize('prnlist', [40000 1]);
eml.varsize('t', [40000 1]);
eml.varsize('elset', [40000 1]);
eml.varsize('dcbsat', [32 2]);
eml.extrinsic('fprintf')
eml.extrinsic('format')

c = 299792458.0; % speed of light in m/s
gamma = (77./60.)^2;
if nargin<6, dt=60; end

% t_diff = int32(lon/15);
% t_start_ngt = mod((21 - t_diff)*3600,86400);
% t_stop_ngt  = mod(( 3 - t_diff)*3600,86400);
% tmp=0;
%% john: pre-read
factor=1.e-9*c/(gamma-1.);
jarray=zeros (8000,3,15,'double');
format;
iarray = zeros(8000,'int8');

sodi=0; %arrays start at 1 here...
for sod=0:dt:86400-1
    sodi=sodi+1;
    sodrow=find(t==sod & ~isnan(iphi));
    if ~isempty(sodrow)
        obsnum=size(sodrow,1);
        count=0;
        for n=1:obsnum
            el = elset(sodrow(n));
            if el>mask
                count=count+1;
                satdcbrow=find(dcbsat(:,1)==prnlist(sodrow(n)),1);
                % the idea is to save time bei not doing these calculations over and over
                jarray(sodi,1,count)=1./obl(el*pi/180.);
                %                         jarray(sodi,2,count)=   (iphi(sodrow(n))-(dcbsat(satdcbrow,2))  *factor);%/obl(el*pi/180);
                jarray(sodi,2,count)=   (iphi(sodrow(n))  );
                jarray(sodi,3,count)=  (dcbsat(satdcbrow(1),2)  );
            end
        end
        iarray(sodi)=count;
    end
end
nsodi=sodi;
viono=zeros(15);
%%
% global Yvals Xvals COUNT;%testing only
COUNT=1;
TOL=1e-3;
MAX_ITER=50;
dcb = findminimumIFB(nsodi,jarray,iarray,factor,TOL,MAX_ITER);
%                plot(Xvals,Yvals);
%               pause;

%%
%{
% John: In 1 or two cases the ifb value differs from the original by .02
% I modified the code [in case of round- and cut-off errors]
%(comments above and below) to calculate as the
% original. --> No change
% The difference must come from the storage. [cut-off]
% solved:
% --jarray has to be declared as double for no 'ifb-'file difference
%
br = -50.;
estdb = [10. 1. 0.1 0.01];
for db = estdb
    stddiff=-10e10;     stdpre=10e10;
    while stddiff<=0
        %stdsum=0;
        stdsum= diffifb(nsodi,jarray,iarray,factor,br);
%{
        for sodi=1:nsodi
             viono=0;
             for ii=1:iarray(sodi);
 %                        viono(ii)=(jarray(sodi,2,ii)-(br)*factor)/jarray(sodi,1,ii);
                        viono(ii)=( jarray(sodi,2,ii)- (br+jarray(sodi,3,ii))*factor )*jarray(sodi,1,ii);
             end
             stdsum=stdsum+std(viono,1);
        end
%}
        stddiff=stdsum-stdpre;
        stdpre=stdsum;
        brpre=br;
        br=br+db;
    end
    br=brpre-2.*db;
end
dcb=brpre-db;
%}
end
%%
%{
function ifbmin=fdsf(nsodi,jarray,iarray,factor,br)
    brstart=-50
    brend=50
end
%}
%% minimize this over br:
function stdsum= diffifb(nsodi,jarray,iarray,factor,br)
% global Yvals Xvals COUNT;
  eml.varsize('viono', [1 30000],[0 1]);
  viono=ones(1,0);

stdsum=0.;
for sodi=1:nsodi
    viono=0;
    for ii=1:iarray(sodi);
        %                        viono(ii)=(jarray(sodi,2,ii)-(br)*factor)/jarray(sodi,1,ii);
        if ii == 1
        viono = ( jarray(sodi,2,ii)- (br+jarray(sodi,3,ii))*factor )*jarray(sodi,1,ii);
        else
         viono=[viono,( jarray(sodi,2,ii)- (br+jarray(sodi,3,ii))*factor )*jarray(sodi,1,ii)]; %#ok<AGROW>
        end
    end
    stdsum=stdsum+std(viono,1);
end
% testing:
%        Xvals(COUNT)=br;
%       Yvals(COUNT)=stdsum;
%      COUNT=COUNT+1;
end
%% find a 3-bracket:  x0<x1<x2,  y1< min{y0, y2}
function [x y]=find3bracket(nsodi,jarray,iarray,factor)
eml.extrinsic('fprintf')
x=zeros(3,'double');
y=zeros(3,'double');
x(1)=-50.;
x(2)=0.;
x(3)=50.;
y(1)=diffifb(nsodi,jarray,iarray,factor,x(1));
y(2)=diffifb(nsodi,jarray,iarray,factor,x(2));
y(3)=diffifb(nsodi,jarray,iarray,factor,x(3));
%    fprintf(1,'                          initial values %f %f %f\n',y(1),y(2),y(3));

while(1)
    if  (y(2) < y(1) )&(y(2) < y(3) )
        return;
    end
    fprintf(1,'initial points not good - correcting\n');
    if  (y(2) > y(1) )
        x(1)=x(1)-50.;
        y(1)=diffifb(nsodi,jarray,iarray,factor,x(1));
    end
    if  (y(2) > y(3)  )
        x(3)=x(3)+50.;
        y(3)=diffifb(nsodi,jarray,iarray,factor,x(3));
    end
end


%search ...
end
%%
function ifb=findminimumIFB(nsodi,jarray,iarray,factor,TOL,MAX_ITER)
%  global Yvals Xvals COUNT;
%   format long;
Y=0;
xnew = 0;
eml.extrinsic('fprintf')
[x y]=find3bracket(nsodi,jarray,iarray,factor);
l=zeros(3,'double');
iter=0;
calcnew=1;
while(1)
    iter=iter+1;
    if(iter>MAX_ITER)%iteration failed
        fprintf(1,'iteration problem\n');
        %                                        plot(Xvals,Yvals);
        %                                       pause;
        ifb= x(2);% x(2) could be a 'wild one!'
        return
    end
    if calcnew==1
        for i=1:3
            l(i)=x(i)*x(i);
        end
        % quadratic fit: min around x=-b/2a
        xnew= (  ( l(2)- l(3))*y(1) +( l(3) -l(1))*y(2) +( l(1)-l(2))*y(3)  )/...
            (2.*(  (x(2)-x(3))*y(1)+(x(3)-x(1))*y(2)+(x(1)-x(2))*y(3)  ));
        Y = diffifb(nsodi,jarray,iarray,factor,xnew);
    else
        calcnew=1;
    end
    if( xnew >x(2)) % n
        if ( Y > y(2))
            x(3)=xnew;y(3)=Y;  % 0 1 n
        else
            x(1)=x(2);y(1)=y(2); % 1 n 2
            x(2)=xnew;y(2)=Y;
        end
    elseif( xnew <x(2))
        if ( Y > y(2))
            x(1)=xnew;y(1)=Y; % n 1 2
        else
            x(3)=x(2);y(3)=y(2);% 0 n 1
            x(2)=xnew;y(2)=Y;
        end
    else
        %                                        if(xnew==x(2))%no new point
        if( (x(3)-x(1)) <=TOL)
            ifb=x(2);
            return;
        else
            if((x(2)-x(1)) < (x(3)-x(2)))
                xnew=x(2)+TOL/2.;
            else
                xnew=x(2)-TOL/2.;
            end
            Y = diffifb(nsodi,jarray,iarray,factor,xnew);
            calcnew=0;
        end
    end
    if( (max(y(1),y(3))-y(2)) <TOL)
        ifb=x(2);
        return;
    end
    if( (x(3)-x(1)) <TOL)
        ifb=x(2);
        return
    end
end
end
%%


%% Receiver Bias Estimation
%{
%somewhat original version
br = -50;
estdb = [10 1 0.1 0.01];
for db = estdb
    stddiff=-10e10;     stdpre=10e10;
    while stddiff<=0
        stdsum=0;
        sodi=0;%john
        for sod=0:dt:86400-1
            sodi=sodi+1;%john
%         for sod=t_start_ngt:dt:t_stop_ngt
             sodrow=find(t==sod & ~isnan(iphi));
             if ~isempty(sodrow)
                 obsnum=size(sodrow,1);
                 viono=0;    count=0;
                 for n=1:obsnum
                     el = elset(sodrow(n));
                     if el>mask
                         count=count+1;
                         satdcbrow=find(dcbsat(:,1)==prnlist(sodrow(n)),1);
                         viono(count)=(jarray(sodi,count)-(br)*1.e-9*c/(gamma-1))/obl(el*pi/180);
%                         viono(count)=(iphi(sodrow(n))-(br+dcbsat(satdcbrow,2))...
 %                            *1.e-9*c/(gamma-1))/obl(el*pi/180);
                     end
                 end
                 stdsum=stdsum+std(viono,1);
%		 fprintf(1,'count = %i\n',count);% <=35 % almost always <=7
             end
        end
        stddiff=stdsum-stdpre;
        stdpre=stdsum;
        brpre=br;
        br=br+db;
    end
    br=brpre-2*db;
end
dcb=brpre-db;
%}