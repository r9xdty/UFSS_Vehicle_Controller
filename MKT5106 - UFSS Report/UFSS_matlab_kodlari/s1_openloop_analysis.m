%% s1_openloop_analysis.m  —  ACIK-CEVRIM ANALIZI (KUTUP/SIFIR + ROOT-LOCUS + STEP)
%  >>> ODEVDE ISTENEN "bastaki 2 acik-cevrim fonksiyonunun pzmap/rlocus/step" <<<
%  Bu betik, kontrolcu eklenmeden once iki plantin davranisini grafiklerle gosterir:
%   Sekil 1: Kutup-sifir haritalari (pzmap)  — her iki kanal
%   Sekil 2: Kok yer egrileri (rlocus)        — her iki kanal (zeta=0.559 izgaralı)
%   Sekil 3: Acik-cevrim birim basamak yaniti — her iki kanal
%  Calistir:  >> s1_openloop_analysis
clear; clc; close all;
s = tf('s');
G_psi = -0.25*(s+0.437)/(s*(s+2)*(s+1.29)*(s+0.193));
G_th  = -0.25*(s+0.435)/((s+2)*(s+1.23)*(s^2+0.226*s+0.0169));

%% --- SEKIL 1: Kutup-Sifir Haritalari ---
figure('Name','Acik-cevrim kutup-sifir haritalari','Color','w');
subplot(1,2,1); pzmap(G_psi); grid on; title('Heading: dr \rightarrow \psi'); sgrid;
subplot(1,2,2); pzmap(G_th);  grid on; title('Pitch: de \rightarrow \theta'); sgrid;
% Heading: orijinde integrator (s=0) dikkat ceker -> Type-1
% Pitch:   orijine cok yakin yavas kompleks cift (-0.113+-j0.064) -> zorlu

%% --- SEKIL 2: Kok Yer Egrileri (root-locus) ---
% NOT: plant kazanci negatif oldugundan, fiziksel olarak anlamli (net pozitif)
% kok yer egrisi icin -G kullanilir (negatif geri besleme ile kapali-cevrim).
figure('Name','Acik-cevrim kok yer egrileri','Color','w');
subplot(1,2,1); rlocus(-G_psi); sgrid(0.559,0); axis([-3 0.5 -3 3]);
title('Heading kok yer egrisi  (-G_{\psi})');
subplot(1,2,2); rlocus(-G_th);  sgrid(0.559,0); axis([-3 0.5 -3 3]);
title('Pitch kok yer egrisi  (-G_{\theta})');
% sgrid(0.559,0): zeta=0.559 (yani %12 asim) dogrusunu cizer. Egrinin bu
% dogruyu kestigi nokta, sadece kazancla ulasilabilen %12-asim noktasidir.

%% --- SEKIL 3: Acik-cevrim birim basamak yaniti ---
figure('Name','Acik-cevrim birim basamak','Color','w');
subplot(1,2,1); step(G_psi,40); grid on; title('Heading acik-cevrim (integrator -> sinirsiz)');
subplot(1,2,2); step(G_th,40);  grid on; title('Pitch acik-cevrim (Type-0, ~35 s yavas)');

%% --- Konsol: pitch yavas kompleks ciftin wn, zeta ---
p = pole(G_th); pc = p(abs(imag(p))>1e-6); pc = pc(1);
wn = abs(pc); zt = -real(pc)/wn;
fprintf('Pitch yavas kompleks cift: wn=%.3f, zeta=%.3f (yavas ama IYI sonumlu)\n', wn, zt);
fprintf('Heading: s=0 integratoru var -> acik-cevrim basamaga sinirsiz buyur.\n');
