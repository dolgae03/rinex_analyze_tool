%
%   Objective : code-carrier smoothing
%
%   Input
%       rho : code measurement
%       phi : carrier measurement
%       M   : length of smoothing window
%
%   Output
%       rhonew : smoothed code measurement
%
%   Version 1.0
%
%   Programmed by Jung Sungwook, 14 Mar. 2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rhonew = smooth_rho(rho,phi,M)

N=size(rho,1);
rhonew=zeros(size(rho));
%M=5;

% rhonew(1)=rho(1);
rhonew(1) = firstirho(rho,phi,N);
for n=2:N
    rhonew(n)=rho(n)/M+(rhonew(n-1)+phi(n)-phi(n-1))*(M-1)/M;
end

function rhobar = firstirho(rho,phi,N)
rhobar=0;
for n=2:N
    rhobar = rhobar + rho(n)-(phi(n)-phi(1));
end
rhobar = rhobar/(N-1);