% See effect of CSM for absolute values (strength of sources) and effect of
% phase differences (phase shifts between mics), by randomizing it
% independently.

%   Anwar Malgoezar, April 2018. 
%   Group ANCE

clearvars;
addpath('.\Program Files');

c = 343.2;
bf_freq = 4000;
N_grid1D = 100;
x_range = 1*[-1 1];
y_range = 1*[-1 1];
z_range = 1.47;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';
% mic_pos = 2*rand(15,2)-1; 
% mic_pos(:,3) = 0;

% source_info = [0 .05 z_range bf_freq 100; ...
%                0 -.15 z_range bf_freq 100];
           
source_info = [0 0 z_range bf_freq 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c);

[CSM, freqs] = developCSM(p.', bf_freq, bf_freq, Fs, size(p,2)/Fs, 0);
[X, Y, B] = FastBeamforming3(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);
                         
randAmp = (max(abs(CSM(:)))-min(abs(CSM(:))))*rand(64,64)+min(abs(CSM(:)));
randAmp = triu(randAmp) + triu(randAmp,1).';
CSM2 = randAmp.*exp(1i*angle(CSM));
[X2, Y2, B2] = FastBeamforming3(CSM2, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);

randAng = 2*pi*rand(64,64) - pi;
randAng = triu(randAng,1) - triu(randAng,1).' ;
CSM3 = abs(CSM).*exp(1i*randAng);


randAngLittle = (2*pi*rand(64,64) - pi)/2;
randAngLittle = triu(randAngLittle,1) - triu(randAngLittle,1).' ;
CSM4 = abs(CSM).*exp(1i*(angle(CSM)+randAngLittle));

[X3, Y3, B3] = FastBeamforming3(CSM4, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);
                         
%%
figure('position', [200 200 1500 500]);

BB = 20*log10(sqrt(real(B))/2e-5);
subplot(1,3,1);
imagesc(X,Y,BB);
title(['max: ' num2str(max(BB(:))) ' dB']);
axis equal; axis([x_range y_range]);
colorbar; caxis([75 100]);
axis xy;

BB2 = 20*log10(sqrt(abs(real(B2)))/2e-5);
subplot(1,3,2); imagesc(X,Y,BB2);
title(['Effect of random amplitudes, max: ' num2str(max(BB2(:))) ' dB']);
axis equal; axis([x_range y_range]);
colorbar; caxis([75 round(max(BB2(:)))]);
axis xy;

BB3 = 20*log10(sqrt(abs(real(B3)))/2e-5);
subplot(1,3,3); imagesc(X,Y,BB3);
title(['Effect of random phases, max: ' num2str(max(BB3(:))) ' dB']);
axis equal; axis([x_range y_range]);
colorbar; caxis([75 round(max(BB3(:)))]);
axis xy;