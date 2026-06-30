%% s2_textbook_controller.m  —  DERS KITABI (NISE) RATE-FEEDBACK KONTROLCUSU
%  Acisal hiz (rate) geri beslemeli iki-cevrimli yapi:  u = -K1*psi - K2*psi_dot
%  K1=K2 secilince geri besleme yolu K1(s+1) olur -> s=-1 sifiri kok yer egrisini
%  sola buker. Bu betik yapiyi yeniden uretir ve neden Ts=3'u tutturamadigini gosterir.
%  Sekil 1: rate-feedback kok yer egrisi    Sekil 2: kapali-cevrim basamak yaniti
clear; clc; close all;
s = tf('s');
G_psi = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));

K1 = 13.71; K2 = 13.71;                 % %10 asim icin (aci/genlik kosulundan)
P   = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));
Pin = feedback(-P, K2*s);               % ic cevrim (yaw-rate jiroskobu)
T_tb= minreal(feedback(K1*Pin, 1));     % dis cevrim (konum)

% --- Kok yer egrisi: rate fb'nin ekledigi s=-1 sifiri gorunur ---
L = 0.25*(s+0.437)*(s+1)/(s*(s+2)*(s+1.29)*(s+0.193));   % G(s)H(s), K1=K2
figure('Name','Ders kitabi rate-fb kok yer egrisi','Color','w');
rlocus(L); sgrid(0.559,0); axis([-3 0.5 -3 3]);
title('Heading ders kitabi (rate-fb) — s=-1 sifiri egriyi sola buker');

% --- Kapali-cevrim yanit + metrikler ---
info = stepinfo(T_tb,'SettlingTimeThreshold',0.02);
figure('Name','Ders kitabi kapali-cevrim basamak','Color','w');
step(T_tb,12); grid on;
title(sprintf('Ders kitabi: OS=%.1f%%, Ts=%.2fs (Ts=3 SAGLANMAZ)', ...
      info.Overshoot, info.SettlingTime));

fprintf('Kapali-cevrim kutuplari:\n'); disp(pole(T_tb).');
fprintf('OS=%.1f%%  Ts=%.2fs  Tp=%.2fs  ess=%.3f\n', ...
        info.Overshoot, info.SettlingTime, info.PeakTime, 1-dcgain(T_tb));
fprintf('--> Baskin cift -1.069+-j1.474 yaninda -0.675,-0.669 YAVAS kutuplari var;\n');
fprintf('    bunlar gercek yerlesmeyi 6.78 s''e cikarir (2. derece yaklasim gecersiz).\n');
