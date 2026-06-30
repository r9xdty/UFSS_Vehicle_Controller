%% s0_model.m  —  UFSS MODEL TANIMI (TEMEL DOSYA)
%  Bu dosya iki kanalin aktarim fonksiyonlarini, durum-uzayi gosterimini ve
%  temel ozellikleri (kutup/sifir, kontrol edilebilirlik/gozlemlenebilirlik)
%  kurar. Diger butun s1..s7 betikleri bu modeli kullanir.
%  Calistir:  >> s0_model
clear; clc; close all;
s = tf('s');

% --- Aktarim fonksiyonlari (odevdeki blok diyagramlarindan) ---
% Heading (yaw):  aktuator 2/(s+2) * arac -0.125(s+0.437)/((s+1.29)(s+0.193)) * 1/s
G_psi = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));      % dr -> psi  (Type-1)
% Pitch/derinlik: aktuator 2/(s+2) * arac -0.125(s+0.435)/(s+1.23) * 1/(s^2+0.226s+0.0169)
G_th  = -0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169)); % de -> theta (Type-0)

% --- Durum-uzayi gosterimi (kontrol edilebilir kanonik form) ---
sys_psi = ss(G_psi);   sys_th = ss(G_th);

% --- Konsol ciktilari: kutup, sifir, DC kazanc, rank ---
fprintf('==== HEADING (dr->psi) ====\n');
fprintf('Kutuplar: '); disp(pole(G_psi).');
fprintf('Sifirlar: '); disp(zero(G_psi).');
fprintf('ctrb rank = %d , obsv rank = %d  (4 = tam)\n', ...
        rank(ctrb(sys_psi.A,sys_psi.B)), rank(obsv(sys_psi.A,sys_psi.C)));
fprintf('\n==== PITCH (de->theta) ====\n');
fprintf('Kutuplar: '); disp(pole(G_th).');
fprintf('Sifirlar: '); disp(zero(G_th).');
fprintf('DC kazanc = %.3f  (Type-0 -> sonlu kalici hata)\n', dcgain(G_th));
fprintf('ctrb rank = %d , obsv rank = %d  (4 = tam)\n', ...
        rank(ctrb(sys_th.A,sys_th.B)), rank(obsv(sys_th.A,sys_th.C)));

% --- Performans hedefi (OS<=12%, Ts<=3s) -> baskin kutup ---
OS=0.12; Ts=3;
zeta = -log(OS)/sqrt(pi^2+log(OS)^2);   % = 0.559
wn   = 4/(zeta*Ts);                     % = 2.383
sstar= -zeta*wn + 1i*wn*sqrt(1-zeta^2); % = -1.333 + j1.976
fprintf('\nHedef: zeta=%.3f, wn=%.3f, s* = %.3f +/- j%.3f\n', ...
        zeta, wn, real(sstar), imag(sstar));
