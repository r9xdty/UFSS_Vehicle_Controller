%% s4_statespace_design.m  —  KENDI TASARIMIM: DURUM-UZAYI (FSF + GOZLEMCI)
%  (a) Tam-durum geri besleme: tum kutuplari yerlestir, BIRINI tam -0.437 sifirinin
%      ustune koy (residusu sifirla -> dev asim engellenir). u = -Kx + Nbar*r.
%  (b) Cikis geri besleme: konum + acisal hiz jiroskobu olcumuyle Luenberger gozlemci.
%  Sekil 1: FSF basamak (her iki kanal)   Sekil 2: heading kapali-cevrim kutup haritasi
clear; clc; close all;
s = tf('s');
G = {  -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193)) , ...   % heading
       -0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169)) };  % pitch
name = {'Heading','Pitch'};

zeta=0.559; wn=2.383; sig=zeta*wn; wd=wn*sqrt(1-zeta^2);
figure('Name','Durum-uzayi FSF basamak','Color','w');
for i=1:2
  sys=ss(G{i}); A=sys.A; B=sys.B; C=sys.C;
  z = zero(G{i}); z = z(1);                          % yavas plant sifiri
  pdes = [-sig+1i*wd, -sig-1i*wd, z, -10];           % bir kutbu sifirin ustune
  K = place(A,B,pdes);
  Nbar = -1/(C/(A-B*K)*B);                           % referans olcekleme
  cl = ss(A-B*K, B*Nbar, C, 0);
  info = stepinfo(cl,'SettlingTimeThreshold',0.02);
  subplot(1,2,i); step(cl,6); grid on;
  title(sprintf('%s FSF: OS=%.1f%%, Ts=%.2fs', name{i}, info.Overshoot, info.SettlingTime));
  fprintf('%s FSF: K=[%.2f %.2f %.2f %.2f], Nbar=%.2f, OS=%.1f%%, Ts=%.2fs\n', ...
          name{i}, K, Nbar, info.Overshoot, info.SettlingTime);

  % --- Cikis geri besleme: gozlemci (yalnizca heading icin gosterim) ---
  if i==1
    Cm = [C; C*A];                                   % olcum: [konum; acisal hiz]
    fprintf('  obsv(A,Cm) rank = %d (4=gozlemlenebilir)\n', rank(obsv(A,Cm)));
    Lobs = place(A', Cm', 3*pdes)';                  % gozlemci 3x daha hizli
    fprintf('  Gozlemci kutuplari: '); disp(eig(A-Lobs*Cm).');

    % heading kapali-cevrim kutup haritasi (FSF) + zeta/Ts cizgileri
    figure('Name','Heading kapali-cevrim kutuplar','Color','w');
    plot(real(eig(A-B*K)),imag(eig(A-B*K)),'rs','MarkerFaceColor','r','MarkerSize',9); hold on;
    sgrid(0.559,0); xline(-1.333,'k--'); axis([-12 1 -4 4]); grid on;
    title('Heading FSF kapali-cevrim kutuplari (kesik: \zeta=0.559, dikey: Ts=3s)');
    xlabel('Re'); ylabel('Im');
  end
end
