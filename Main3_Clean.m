clearvars; %close all;
addpath('.\Program Files');

add_on_per = 0*1;
c = 343.2;
bf_freq = 356;
N_grid1D = 100;
x_range = 1*[-1 1];
y_range = 1*[-1 1];
z_range = 1;

D_ap = 1.9;
rangedb = 12;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';

if add_on_per
    n_mic = size(mic_pos,1);
    addition = 16;
    [mic_pos(n_mic+1:n_mic+addition,1), mic_pos(n_mic+1:n_mic+addition,2)] = pol2cart(linspace(0,(2*pi-2*pi/(addition-1)),addition),D_ap*ones(1,addition)/2);
end

% source_info = [0.15 3*0.15 z_range 0*bf_freq 100; ...
%                -.15 -0.15 z_range 0*bf_freq 100];
source_info = [0.15 0.15 z_range bf_freq 100];
% source_info = [.15 0 z_range bf_freq-1 100; ...
%                -.15 0 z_range bf_freq+1 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c, 50e3, 10);

% [CSM, freqs] = developCSM(p.', bf_freq-1, bf_freq+1, Fs, size(p,2)/Fs, 0);
[CSM, freqs] = developCSM(p.', bf_freq-1, bf_freq+1, Fs, 0.5, 0.5, 0, 10);
% 
% [X, Y, B] = FastBeamforming3mod(CSM, z_range, freqs, [x_range y_range], ...
%                              0.01, mic_pos.', c);
% [X, Y, B] = HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
%                              0.01, mic_pos.', c, 2, 0.25);
% [X, Y, B] = adaptive_HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
%                              0.01, mic_pos.', c, 2);
[X, Y, B] = CleanSCmod(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);

if size(source_info,1) == 1
    Rf = z_range*tan(1.22*c/(bf_freq*2));
else
    Rf = 1.22*c/(D_ap*atan((source_info(1,1)-source_info(2,1))/z_range));
end
%%

BB = 20*log10(sqrt(real(B))/2e-5/4/pi);

figure;
imagesc(X,Y,BB);
title(['max: ' num2str(max(BB(:))) ', fr = ' num2str(Rf)]);
axis equal; axis([x_range y_range]);
colorbar; caxis([max(BB(:))-rangedb max(BB(:))]);
axis xy;

% figure; subplot(1,2,1); plot(BB(100,:));subplot(1,2,2); plot(real(B(100,:))); %axis([85 117 4.34 4.38]);