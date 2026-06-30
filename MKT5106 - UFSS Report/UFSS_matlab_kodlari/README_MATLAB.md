# UFSS — MATLAB Betikleri (MKT5106)

Hepsi MATLAB + Control System Toolbox ile çalışır. Her biri kendi figürlerini açar
ve metrikleri konsola basar. İstediğin dosyayı tek başına çalıştırabilirsin; ya da
`run_all` ile hepsini sırayla çalıştır.

| Dosya | Ne işe yarar | Açtığı grafikler |
|---|---|---|
| **s0_model.m** | İki kanalın aktarım fonksiyonu + durum-uzayı tanımı; kutup/sıfır, DC kazanç, ctrb/obsv rank, hedef baskın kutup `s*` hesabı. | (yok — konsol çıktısı) |
| **s1_openloop_analysis.m** | **İstediğin dosya:** kontrolcüsüz iki açık-çevrim plantın analizi. | **pzmap** (kutup/sıfır), **rlocus** (kök yer eğrisi, ζ=0.559 ızgaralı), açık-çevrim **step** — her biri heading + pitch. |
| **s2_textbook_controller.m** | Nise rate-feedback yapısının yeniden üretimi; neden Ts=3'ü tutturamadığı. | rate-fb kök yer eğrisi + kapalı-çevrim step. |
| **s3_rootlocus_design.m** | Kendi lag-lead tasarımın (kutup-sıfır iptali + lead). | rlocus (h/p) + step (h/p). |
| **s4_statespace_design.m** | Tam-durum geri besleme (kutbu sıfıra koyma) + jiroskoplu Luenberger gözlemci. | FSF step (h/p) + heading kapalı-çevrim kutup haritası. |
| **s5_lqr_optimal.m** | **2. aşama:** LQR ile optimal durum geri besleme; efor–hız takası. | ρ taraması overlay + LQR↔FSF step & kontrol işareti karşılaştırması. |
| **s6_effort_disturbance.m** | Kontrol eforu (tepe/ortalama/enerji), giriş bozucu kalıcı sapması, impuls. | kontrol işaretleri + impuls (RL vs FSF). |
| **s7_compare_all.m** | Tüm heading tasarımlarının üst üste karşılaştırması + özet tablo. | overlay step + konsol tablosu. |
| **ufss_build_simulink.m** | Kapalı-çevrim Simulink modelini programatik kurar/çalıştırır (rapor 8.1 görseli buradan). | Simulink modeli + step grafiği. |
| **run_all.m** | s0→s7'yi sırayla çalıştırır. | hepsi. |

## Önerilen çalıştırma sırası
```matlab
s0_model
s1_openloop_analysis     % <-- açık-çevrim pzmap + rlocus + step (senin istediğin)
s2_textbook_controller
s3_rootlocus_design
s4_statespace_design
s5_lqr_optimal
s6_effort_disturbance
s7_compare_all
% Simulink:
ufss_build_simulink('heading')   % veya ('pitch')
```

## İşaret kuralı (önemli)
Plant kazancı negatif (−0.25). Kapalı-çevrim için kompansatör `-Ch`/`-Cp` ile girilir;
böylece açık-çevrim `(-C)·G` **net pozitif** olur ve birim negatif geri beslemeyle
doğru sonuç çıkar. (`feedback(-Ch*G_psi,1)` ile birebir aynı; Simulink'te kompansatör
blok katsayısı negatif girilir.)
