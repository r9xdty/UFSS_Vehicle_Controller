%% 
%% s6_effort_disturbance.m  —  KONTROL EFORU, GIRIS BOZUCU, IMPULS YANITI
%  - Kontrol isareti u(t): tepe, ortalama, enerji (int u^2 dt)
%  - Giris bozucu: plant girisine basamak -> cikistaki KALICI sapma (t->inf)
%  - Impuls yanitlari (RL vs FSF)
clear; clc; close all;
s = tf('s');
G_psi=-0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));
G_th =-0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169));
Ch=119.7*(s+0.193)*(s+1.3)/((s+0.437)*(s+12));
Cp=112.6*(s^2+0.226*s+0.0169)*(s+1.3)/(s*(s+0.435)*(s+12));
t=linspace(0,60,30000);

fprintf('--- Kontrol eforu (RL, birim basamak referans) ---\n');
for k=1:2
  if k==1, Cc=Ch; G=G_psi; nm='Heading'; else, Cc=Cp; G=G_th; nm='Pitch'; end
  S = minreal(1/(1+(-Cc*G)));          % duyarlilik
  u = step(minreal(Cc*S), t);          % r->u
  Td= minreal(G*S);                    % giris bozucu -> cikis (y/d)
  yd= step(Td,t);
  fprintf('%s RL: tepe|u|=%.1f  ort|u|=%.2f  enerji=%.0f  bozucu(t->inf)=%.4f\n',...
          nm, max(abs(u)), mean(abs(u)), trapz(t,u.^2), yd(end));
end
fprintf('NOT: Heading''de integrator yok -> kalici -0.175 ofset; Pitch''te integrator var -> 0.\n');

% --- Kontrol isaretleri grafigi ---
figure('Name','Kontrol isaretleri (RL)','Color','w'); tt=linspace(0,4,4000);
uh=step(minreal(Ch*minreal(1/(1+(-Ch*G_psi)))),tt);
up=step(minreal(Cp*minreal(1/(1+(-Cp*G_th)))),tt);
subplot(1,2,1); plot(tt,uh,'LineWidth',1.3); grid on; title('Heading kontrol \delta_r(t)'); xlabel('t[s]');
subplot(1,2,2); plot(tt,up,'LineWidth',1.3); grid on; title('Pitch kontrol \delta_e(t)'); xlabel('t[s]');

% --- Impuls yanitlari: RL vs FSF (heading ornegi) ---
Th=minreal(feedback(-Ch*G_psi,1));
sys=ss(G_psi);A=sys.A;B=sys.B;C=sys.C; zeta=0.559;wn=2.383;sig=zeta*wn;wd=wn*sqrt(1-zeta^2);
Kf=place(A,B,[-sig+1i*wd,-sig-1i*wd,-0.437,-10]); Nf=-1/(C/(A-B*Kf)*B);
Tf=ss(A-B*Kf,B*Nf,C,0);
figure('Name','Impuls yanitlari','Color','w');
impulse(Th,8); hold on; impulse(Tf,8); grid on; legend('RL','FSF');
title('Heading impuls yaniti: RL vs FSF');
