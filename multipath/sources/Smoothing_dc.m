function [smoothed_psr, count_new, piLast] = Smoothing_dc(psr, pi, count, pi_prev, smoothed, win)
c = 299792458.0; % speed of light in m/s
f_1          = 1575.42e6;            % L1 frequency, Hz
lambda_1     = c/f_1;   

if count==0
    smoothed_psr=psr;
else
    if count<=win
        win=count;
    end
        smoothed_psr=psr/win+(smoothed+pi*lambda_1-pi_prev*lambda_1)*(win-1)/win;
end

count_new=count+1;
piLast=pi;
