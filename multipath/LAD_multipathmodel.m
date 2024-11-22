% type=1;
coeff_noise=[0.093 0.26 16.4
    0.029 0.081 16.4
    0.034 0.024 36.9];

coeff_mul=[0.5 1.64 14.5 inf
    0.15 1.06 15 inf
    0.15 0.84 15.8 0.24];

coeff_total=[0.5 1.65 14.3 inf
    0.16 1.07 15.5 inf
    0.15 0.84 15.5 0.24];

xx=0:1:90;

sig_noise=coeff_noise(type,1)+coeff_noise(type,2)*exp(-xx/coeff_noise(type,3));
sig_mul=coeff_mul(type,1)+coeff_mul(type,2)*exp(-xx/coeff_mul(type,3));
sig_total=coeff_total(type,1)+coeff_total(type,2)*exp(-xx/coeff_total(type,3));
if type==3;
    sig_mul(xx<35)=coeff_mul(type,4)*ones(1,sum(xx<35));
    sig_total(xx<35)=coeff_total(type,4)*ones(1,sum(xx<35));
end
sig_total2=sqrt(sig_noise.^2+sig_mul.^2);

% figure()
% plot(xx,sig_noise,'r')
hold on
% plot(xx,sig_mul,'b')
plot(xx,sig_total,'k')
% plot(xx,sig_total2,'ko-')
grid on