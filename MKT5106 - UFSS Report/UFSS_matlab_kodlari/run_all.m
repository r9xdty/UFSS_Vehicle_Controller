%% run_all.m  —  TUM ANALIZ VE TASARIMLARI SIRAYLA CALISTIRIR
%  Her betik kendi figurlerini acar; konsola metrikleri basar.
%  Tek tek de calistirabilirsin (asagidaki sirayla onerilir).
clc; close all;
disp('== s0: model =='),               s0_model
disp('== s1: acik-cevrim analizi =='), s1_openloop_analysis
disp('== s2: ders kitabi kontrolcu =='), s2_textbook_controller
disp('== s3: kok yer egrisi tasarim =='), s3_rootlocus_design
disp('== s4: durum-uzayi tasarim =='), s4_statespace_design
disp('== s5: LQR optimal (2. asama) =='), s5_lqr_optimal
disp('== s6: efor / bozucu / impuls =='), s6_effort_disturbance
disp('== s7: karsilastirma =='),       s7_compare_all
disp('TAMAM. Tum figurler acildi.')
