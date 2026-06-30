%% 
function ufss_build_simulink(kanal)
% UFSS_BUILD_SIMULINK  Kapali-cevrim UFSS Simulink modelini programatik kurar,
% calistirir ve basamak yanitini cizer. Raporun 8.1'deki yer-tutucusunun yerine
% kullanilacak ekran goruntusu bu modelden alinir.
%
% Kullanim:
%   ufss_build_simulink('heading')   % yonelim kanali (RL lag-lead)
%   ufss_build_simulink('pitch')     % derinlik/pitch kanali (RL, integratorlu)
%
% NOT (isaret kurali): Plant kazanci negatif (-0.25) oldugundan, kapali-cevrimin
% kararli olmasi icin kontrolcu blogu NEGATIF kazancla girilir; boylece acik-cevrim
% L = (-C)*G NET POZITIF olur ve birim negatif geri besleme ile dogru sonuc cikar.
% (Rapordaki feedback(-C*G,1) ile birebir ayni.)

if nargin < 1, kanal = 'heading'; end

switch lower(kanal)
    case 'heading'
        mdl     = 'ufss_heading_cl';
        ctrlNum = '-119.7*conv([1 0.193],[1 1.3])';      % -Ch payi
        ctrlDen = 'conv([1 0.437],[1 12])';
        plntNum = '-0.25*[1 0.437]';                     % G_psi payi
        plntDen = 'conv(conv([1 0],[1 2]),conv([1 1.29],[1 0.193]))';
    case 'pitch'
        mdl     = 'ufss_pitch_cl';
        ctrlNum = '-112.6*conv([1 0.226 0.0169],[1 1.3])'; % -Cp payi (integratorlu)
        ctrlDen = 'conv(conv([1 0],[1 0.435]),[1 12])';
        plntNum = '-0.25*[1 0.435]';                       % G_th payi
        plntDen = 'conv(conv([1 2],[1 1.23]),[1 0.226 0.0169])';
    otherwise
        error('kanal "heading" veya "pitch" olmali.');
end

% --- Modeli sifirdan kur ---
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl); open_system(mdl);

add_block('simulink/Sources/Step', [mdl '/Ref'], ...
    'Time','0','Before','0','After','1','Position',[30 100 60 130]);

add_block('simulink/Math Operations/Sum', [mdl '/Sum_e'], ...
    'Inputs','+-','Position',[110 102 130 128]);     % hata = r - y

add_block('simulink/Continuous/Transfer Fcn', [mdl '/Controller'], ...
    'Numerator',ctrlNum,'Denominator',ctrlDen,'Position',[180 95 300 135]);

add_block('simulink/Math Operations/Sum', [mdl '/Sum_d'], ...
    'Inputs','++','Position',[330 102 350 128]);     % giris bozucu toplami

add_block('simulink/Sources/Step', [mdl '/Dist'], ...
    'Time','6','Before','0','After','0', ...         % varsayilan: bozucu KAPALI (After=0)
    'Position',[305 35 335 65]);                     % bozucu calismasi icin After'i 1 yap

add_block('simulink/Continuous/Transfer Fcn', [mdl '/Plant'], ...
    'Numerator',plntNum,'Denominator',plntDen,'Position',[390 95 530 135]);

add_block('simulink/Sinks/Scope', [mdl '/y'], 'Position',[580 100 610 130]);

add_block('simulink/Sinks/To Workspace', [mdl '/y_out'], ...
    'VariableName','y','SaveFormat','Timeseries','Position',[580 165 640 195]);

% --- Baglantilar ---
add_line(mdl,'Ref/1','Sum_e/1','autorouting','on');
add_line(mdl,'Sum_e/1','Controller/1','autorouting','on');
add_line(mdl,'Controller/1','Sum_d/1','autorouting','on');
add_line(mdl,'Dist/1','Sum_d/2','autorouting','on');
add_line(mdl,'Sum_d/1','Plant/1','autorouting','on');
add_line(mdl,'Plant/1','y/1','autorouting','on');
add_line(mdl,'Plant/1','y_out/1','autorouting','on');
add_line(mdl,'Plant/1','Sum_e/2','autorouting','on');   % birim negatif geri besleme

% --- Cozucu ve calistirma ---
set_param(mdl,'StopTime','12','Solver','ode45','RelTol','1e-6');
save_system(mdl);

simOut = sim(mdl);
y = simOut.y;                                 % Timeseries

% --- Performans metrikleri ve cizim ---
info = stepinfo(y.Data, y.Time, 1, 'SettlingTimeThreshold', 0.02);
fprintf('\n[%s] OS = %.2f%%   Ts = %.3f s   Tp = %.3f s   y(end) = %.4f\n', ...
        kanal, info.Overshoot, info.SettlingTime, info.PeakTime, y.Data(end));

figure('Name',['UFSS ' kanal ' kapali-cevrim']);
plot(y.Time, y.Data,'LineWidth',1.4); grid on; yline(1,'k:');
xlabel('t [s]'); ylabel(kanal); title(['UFSS ' kanal ' birim basamak yaniti (Simulink)']);

% Bozucu etkisini gormek icin: Dist blogunda 'After' degerini 1 yapip
% modeli tekrar calistir (set_param([mdl '/Dist'],'After','1'); sim(mdl);).
end
