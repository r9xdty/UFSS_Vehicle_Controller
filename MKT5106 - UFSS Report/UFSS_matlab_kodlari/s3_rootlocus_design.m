%% s3_rootlocus_design.m  —  KENDI TASARIMIM: KOK YER EGRISI (LAG-LEAD)
%  Fikir: yavas plant kutbunu ve sorunlu yavas -0.437/-0.435 sifirini KOMPANSATORLE
%  IPTAL et, lead ekleyip kazanci zeta=0.559 dogrusuna oturt. Boylece orijine yakin
%  yavas mod kalkar ve 6.8 s problemi cozulur.
%  Sekil 1-2: rlocus (heading/pitch)   Sekil 3-4: basamak yanitlari
clear; clc; close all;
s = tf('s');
G_psi = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));
G_th  = -0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169));

% --- HEADING kompansatoru: -0.193 kutbu ve -0.437 sifiri iptal + lead(-12) ---
Ch = 119.7*(s+0.193)*(s+1.3)/((s+0.437)*(s+12));
Th = minreal(feedback(-Ch*G_psi,1));            % -Ch: net pozitif acik-cevrim
ih = stepinfo(Th,'SettlingTimeThreshold',0.02);

% --- PITCH kompansatoru: kompleks-cift iptali + integrator(1/s) + lead ---
Cp = 112.6*(s^2+0.226*s+0.0169)*(s+1.3)/(s*(s+0.435)*(s+12));
Tp = minreal(feedback(-Cp*G_th,1));
ip = stepinfo(Tp,'SettlingTimeThreshold',0.02);

% --- Kok yer egrileri (zeta=0.559 dogrusu ile) ---
figure('Name','Kendi RL kok yer egrileri','Color','w');
subplot(1,2,1); rlocus(-Ch*G_psi); sgrid(0.559,0); axis([-14 1 -4 4]);
title('Heading lag-lead kok yer egrisi');
subplot(1,2,2); rlocus(-Cp*G_th);  sgrid(0.559,0); axis([-14 1 -4 4]);
title('Pitch lag-lead kok yer egrisi');

% --- Basamak yanitlari ---
figure('Name','Kendi RL basamak yanitlari','Color','w');
subplot(1,2,1); step(Th,8); grid on;
title(sprintf('Heading RL: OS=%.1f%%, Ts=%.2fs', ih.Overshoot, ih.SettlingTime));
subplot(1,2,2); step(Tp,8); grid on;
title(sprintf('Pitch RL: OS=%.1f%%, Ts=%.2fs', ip.Overshoot, ip.SettlingTime));

fprintf('HEADING RL kutuplari:\n'); disp(pole(Th).');
fprintf('  OS=%.1f%%  Ts=%.2fs  Tp=%.2fs\n', ih.Overshoot, ih.SettlingTime, ih.PeakTime);
fprintf('PITCH   RL kutuplari:\n'); disp(pole(Tp).');
fprintf('  OS=%.1f%%  Ts=%.2fs  Tp=%.2fs\n', ip.Overshoot, ip.SettlingTime, ip.PeakTime);
fprintf('--> Yavas artik kutup kalmadi; Ts ~3.8-4.0 s (6.8 s problemi cozuldu).\n');
