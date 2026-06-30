%% s5_lqr_optimal.m  —  2. ASAMA: LQR ILE OPTIMAL DURUM GERI BESLEME
%  Kutup-yerlestirmeli FSF spec'i tutturur ama eforu YUKSEKtir (tepe|u|~227).
%  LQR, J=int(x'Qx + R u^2)dt'yi minimize ederek hiz-efor PARETO egrisinde
%  optimum nokta verir: ayni hizda COK daha az eforla.
%  Sekil 1: rho taramasi (efor-hiz takasi)   Sekil 2: LQR vs FSF basamak + kontrol
clear; clc; close all;
s = tf('s');
G = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));   % heading
sys = ss(G); A=sys.A; B=sys.B; C=sys.C;

% --- rho taramasi: cikis agirligi buyudukce hizlanir, efor artar ---
rhos = [3e2 1e3 3e3 1e4]; t=linspace(0,12,12000);
fprintf(' rho      OS%%    Ts(s)  tepe|u|  enerji\n');
figure('Name','LQR rho taramasi','Color','w'); hold on; grid on;
for r = rhos
  Q = r*(C'*C); R = 1;
  K = lqr(A,B,Q,R);  Nbar = -1/(C/(A-B*K)*B);
  cl = ss(A-B*K, B*Nbar, C, 0);  info = stepinfo(cl,'SettlingTimeThreshold',0.02);
  [y,~,x] = lsim(cl, ones(size(t)), t);  u = Nbar - (K*x')';
  fprintf('%6.0f  %5.1f  %6.2f  %7.1f  %6.0f\n', ...
          r, info.Overshoot, info.SettlingTime, max(abs(u)), trapz(t,u.^2));
  plot(t,y,'DisplayName',sprintf('\\rho=%g (Ts=%.1fs)',r,info.SettlingTime));
end
yline(1,'k:'); xlabel('t [s]'); ylabel('\psi'); legend show;
title('LQR: rho buyudukce hizlanir (efor artar)');

% --- En iyi (rho=1e4) LQR vs kutup-yerlestirme FSF: basamak + kontrol isareti ---
r=1e4; Q=r*(C'*C); R=1; Klqr=lqr(A,B,Q,R); Nl=-1/(C/(A-B*Klqr)*B);
cl_lqr=ss(A-B*Klqr,B*Nl,C,0);
zeta=0.559; wn=2.383; sig=zeta*wn; wd=wn*sqrt(1-zeta^2);
pdes=[-sig+1i*wd,-sig-1i*wd,-0.437,-10]; Kfsf=place(A,B,pdes); Nf=-1/(C/(A-B*Kfsf)*B);
cl_fsf=ss(A-B*Kfsf,B*Nf,C,0);
[yl,~,xl]=lsim(cl_lqr,ones(size(t)),t); ul=Nl-(Klqr*xl')';
[yf,~,xf]=lsim(cl_fsf,ones(size(t)),t); uf=Nf-(Kfsf*xf')';

figure('Name','LQR vs FSF','Color','w');
subplot(1,2,1); plot(t,yl,'b',t,yf,'r','LineWidth',1.3); grid on; yline(1,'k:');
xlim([0 6]); legend('LQR','FSF (kutup)'); title('Cikis \psi'); xlabel('t [s]');
subplot(1,2,2); plot(t,ul,'b',t,uf,'r','LineWidth',1.3); grid on;
xlim([0 4]); legend(sprintf('LQR (tepe %.0f)',max(abs(ul))), ...
       sprintf('FSF (tepe %.0f)',max(abs(uf)))); title('Kontrol isareti u'); xlabel('t [s]');
fprintf('\nLQR(rho=1e4) ayni hizda FSF eforunun ~yarisindan azini harcar.\n');
