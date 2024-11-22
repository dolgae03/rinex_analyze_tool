function [arc flag short_num] = cycleslip_qc...
    (t,x,lli,doubt_t,slip_para,eff_slip_para,eff_tintv,small_slip_para)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   cycleslip.m
%
%   Objective : Detect cycle slips and preliminary outliers
%
%   Input
%       t        : time in second of day
%       x        : measurement or observation
%       lli      : Loss of Lock Indicator ( 0 or 1)
%       doubt_t  : time with no measurent
%       slip_para : parameter for cycle slip detection
%       eff_slip_para : paraemter for continuity check between adjacent
%                       arcs in meter.
%       eff_tintv : lenth of effective length of continuous arc
%
%   Output
%       arc     : time tags for effective arc. nx2 dimension. each line
%                 present time information of each arc.
%       flag    : pre-process indicator
%
%   ** Pre-process indicator
%       format : %1d%1d%1d,con_flag,slip_flag,outlier_flag
%       1) con_flag : start point of continuous arc w.r.t time
%           1 : start point
%           0 : normal point
%       2) slip_flag : flags for cycle slip detection
%           bit0 : data jump
%           bit1 : LLI
%           bit2 : data gap
%       3) out_flag : for NaN valued points
%           bit0 : originally NaN. able to realted with bit2 of slip_flag
%           bit1 : short arc removal
%           bit2 : interpreted as outliers
%
%   Version 2.0
%
%   Version upgrade (v 2.0)
%      Modification of flags related to pre-process
%
%   Written by Jung Sungwook, 29 Mar. 2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag = zeros(size(t,1),1);
flag(1,1) = 100;

%% Cycle Slip Detection
dx = abs(diff(x));
%dt = diff(t);
jump_rows1=find(dx>slip_para);   % 1. cycle slip by data jump
if ~isempty(jump_rows1)
    flag(jump_rows1+1)=flag(jump_rows1+1)+10*1;
end
jump_rows2=find(lli(2:end)~=0);  % 2. cycle slip by LLI
if ~isempty(jump_rows2)
    flag(jump_rows2+1)=flag(jump_rows2+1)+10*2;
end

% small_rows=find(dx>small_slip_para);
% small_jump_rows = [];
% if ~isempty(small_rows)
%     for n = 1:size(small_rows,1)
%         jump_t = t(small_rows(n));
%         row_nbr_more=find((t-jump_t)<=30*5 & (t-jump_t)>=0 &t~=t(small_rows(n)));
%         if ~isempty(row_nbr_more) && (size(dx,1) < row_nbr_more(end))
%             row_nbr_more(end) = [];
%         end      
%         row_nbr_less=find((jump_t-t)<=30*5 & (jump_t-t)>=0 & t~=t(small_rows(n)));   
%         if isempty(find(dx(row_nbr_more) > small_slip_para)) && isempty(find(dx(row_nbr_less) > small_slip_para))
%             small_jump_rows = [small_jump_rows; small_rows(n)];
%             flag(small_rows(n)+1)=flag(small_rows(n)+1)+10*1;
%         end
%     end
% end
% jump_rows=unique([jump_rows1; jump_rows2;small_jump_rows]);

jump_rows=unique([jump_rows1; jump_rows2]);
% Add doubt cycle slips (3. by data gap)
if ~isempty(doubt_t)
    for n=1:size(doubt_t,1)
        slip_jump_row=find(t<doubt_t(n),1,'last');
        if fix(rem(flag(slip_jump_row+1),100)/40)~=1
            flag(slip_jump_row+1)=flag(slip_jump_row+1)+10*4;
            jump_rows=unique([jump_rows; slip_jump_row]);
        end % Not to be duplicated
    end
end
arc=zeros(size(jump_rows,1),2);
arc(1,1)=t(1);     % start of the first arc

%% Specific Investigation
short_num = 0;
if ~isempty(jump_rows)
    % Total arcs
    for n=1:size(jump_rows)
        arc(n,2)   = t(jump_rows(n));
        arc(n+1,1) = t(jump_rows(n)+1);
    end
    arc(n+1,2) = t(end);
    % Kill Short Arcs
    arc_interval_tmp=diff(arc')';
    short_arc_row = find(arc_interval_tmp<=eff_tintv);
    if ~isempty(short_arc_row)
        for n=1:size(short_arc_row,1)
            short_num = size(short_arc_row,1);
            killrows = t>=arc(short_arc_row(n),1) & ...
                t<=arc(short_arc_row(n),2);
            flag(killrows)=flag(killrows)+2;
        end
    end
    
%     % Continuity Check Renewed
%     if ~isempty(short_arc_row)
%         for n=1:size(short_arc_row,1)
%             killarc=arc(short_arc_row(n),:);
%             killedrow = find(t>=arc(short_arc_row(n),1) & ...
%                 t<=arc(short_arc_row(n),2),1,'first');
%             if rem(fix(flag(killedrow)/10),2)~=1, continue, end % Only merging for data jump slip
%             killedflag=fix(rem(flag(killedrow),100)/10);
%             if fix(killedflag/4)>0, continue, end % Only merging for data jump slip
%             if fix(killedflag/2)>0, continue, end % Only merging for data jump slip
%             [arcrow1 arcrow2]=bothsidearc(t,jump_rows,arc,flag,killarc);
%             if isempty(arcrow1) || isempty(arcrow2), continue, end
%             tmp_t=t([arcrow1(1):arcrow1(2) arcrow2(1):arcrow2(2)]);
%             tmp_x=x([arcrow1(1):arcrow1(2) arcrow2(1):arcrow2(2)]);
%             order=4+int8((tmp_t(end)-tmp_t(1))/3600);
%             p=polyfit(tmp_t,tmp_x,order);
%             res=tmp_x-polyval(p,tmp_t);
%             check_row=find(tmp_t==t(arcrow1(2)));
%             if abs(res(check_row+1)-res(check_row))<eff_slip_para
%                 killrows = find(t>=killarc(1) & t<=killarc(2));
%                 flag(killrows)=flag(killrows)+4;    % outlier polocy for short arc
%                 tmp=flag(killrows(1));
%                 flag(killrows(1))=tmp-fix(rem(tmp,100)/10)*10; % no slip on short arc
%                 nosliprow = find(t==arcrow2(1));
%                 tmp=flag(nosliprow);
%                 flag(nosliprow)=tmp-fix(rem(tmp,100)/10)*10;   % merging arcs and inactivate the slip flag
%             end
%         end
%     end
else
    arc(1,:)=[t(1) t(end)];
end

%% arc return
start_row=find(fix(flag/10)>0 & rem(flag,10)==0);
arc=zeros(size(start_row,1),2);
arc(:,1)=t(start_row);
for n=1:size(arc,1)
    if n<size(arc,1)
        stop_row=find(t<arc(n+1,1) & rem(flag,10)~=2 & rem(flag,10)~=4,...
            1,'last');
    else
        stop_row=find(rem(flag,10)~=2 & rem(flag,10)~=4,1,'last');
    end
    arc(n,2)=t(stop_row);
end

% arc_tmp=arc;
% for n=1:size(arc_tmp,1)
%     test_flag=flag(t==arc_tmp(n,1));
%     if fix(test_flag/10)==0     % when arcs on both sides were merged into
%         arc_tmp(n,:)=NaN;
%     end
% end
% tmp=~isnan(arc_tmp);
% arc=arc(tmp(:,1),:);

function [arcrow1 arcrow2]=bothsidearc(t,jump_rows,arc,flag,killarc)
arcrow1=[]; arcrow2=[];
% previous arc
startrow=find(t<killarc(1) & ...
    (fix(flag/100)==1 | ismember(t,t(jump_rows+1))) & (rem(flag,10)~=2 & rem(flag,10)~=4),1,'last');
if isempty(startrow), return, end
stoprow= find(t==arc(arc(:,1)==t(startrow),2));
arcrow1=[startrow stoprow];
% next arc
startrow=find(t>killarc(2) & ...
    ismember(t,t(jump_rows+1)) & (rem(flag,10)~=2 & rem(flag,10)~=4),1,'first');
if isempty(startrow), return, end
stoprow= find(t==arc(arc(:,1)==t(startrow),2));
arcrow2=[startrow stoprow];
