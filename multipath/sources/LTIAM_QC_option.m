%
%   KIMOS_option.m
%
%   Objective : A declaration of parameters and paths for KIMOS
%
%   Version   : 1.0
%
%   Written by Sungwook Jung, 17 June, 2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Basic 
baseline    = 100;      % the maximum distance between two stations, in km
tintv       = 30;       % sampling time in sec
maskangle   = 10;       % in degrees
slip_mp_para = 10;

% Pre-Processing
con_arc         = 3600;     % continuous arc parameter in second
allow_arc_len   = 50;      % minimum length of allowed arc in second
allow_arc_pnt   = 20;       % minimum data number of allowed arc
slip_para       = 0.08;      % cycle slip parameter in meter
eff_slip_para   = 0.8;  % parameter for continuity check 
                        % between adjacent arcs in meter
out_para    = 0.08;      % outlier parameter to be used in poly-fit (Iphi) - meter
out_para_rho = 10;      % outlier parameter to be used in poly-fit (Irho) - meter
smoothwin   = 5;        % length of smoothing window in code smoothing
small_slip_para = 0.5;

% Auto Screening
thslope     = 200;      % threshold for ionospheric gradient mm/km
negiono     = true;     % Negative iono. delay check for large gradient
clumpslope  = true;     % Check for a excessive bias of iono. gradient
clumpbound  = 50;       % Boundary from the mean value for the excessive
                        %   iono. gradient check in mm/km
clumpratio  = 100;      % Ratio within the given boundary of iono. gradient
                        %   in percentage
