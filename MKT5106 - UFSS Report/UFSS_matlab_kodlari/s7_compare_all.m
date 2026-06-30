%% s7_compare_all.m  —  TUM TASARIMLARIN KARSILASTIRMASI (OVERLAY + OZET TABLO)
%  Heading icin: ders kitabi (rate-fb), kendi RL, durum-uzayi FSF basamak
%  yanitlarini ust uste cizer ve metrik tablosunu konsola basar.
clear; clc; close all;
s = tf('s');
G_psi=-0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));
G_th =-0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169));

% Ders kitabi
K1=13.71; Pin=feedback(-G_psi,K1*s); Ttb=minreal(feedback(K1*Pin,1));
% Kendi RL
Ch=119.7*(s+0.193)*(s+1.3)/((s+0.437)*(s+12)); Trl=minreal(feedback(-Ch*G_psi,1));
% FSF
sys=ss(G_psi);A=sys.A;B=sys.B;C=sys.C; zeta=0.559;wn=2.383;sig=zeta*wn;wd=wn*sqrt(1-zeta^2);
Kf=place(A,B,[-sig+1i*wd,-sig-1i*wd,-0.437,-10]); Nf=-1/(C/(A-B*Kf)*B);
Tfsf=ss(A-B*Kf,B*Nf,C,0);

figure('Name','Heading karsilastirma','Color','w');
step(Ttb,10); hold on; step(Trl,10); step(Tfsf,10); grid on; yline(1,'k:');
legend('Ders kitabi (rate-fb)','Kendi root-locus','Durum-uzayi FSF','Location','SE');
title('HEADING — birim basamak yaniti karsilastirmasi');

% --- Ozet tablo ---
dess={'Ders kitabi','Kendi RL','FSF'}; T={Ttb,Trl,Tfsf};
fprintf('\n%-14s %7s %7s %7s\n','Tasarim','OS(%)','Ts(s)','Tp(s)');
for i=1:3
  in=stepinfo(T{i},'SettlingTimeThreshold',0.02);
  fprintf('%-14s %7.1f %7.2f %7.2f\n',dess{i},in.Overshoot,in.SettlingTime,in.PeakTime);
end
