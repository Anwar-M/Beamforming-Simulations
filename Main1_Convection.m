% The basic beamforming including convection. Generate simulated data, for 
% single or multiple sources in the wind and perform conventional
% beamforming CORRECTING the wind.
%

%   Anwar Malgoezar, May 2018. 
%   Group ANCE

clearvars;
addpath('.\Program Files');

c = 343.2;
bf_freq = 2000;
N_grid1D = 100;
x_range = 1*[-1 1];
y_range = 1*[-1 1];
z_range = 1;
dBrange = 12*2;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';
% mic_pos = 2*rand(15,2)-1; 
% mic_pos(:,3) = 0;

% source_info = [-.20 0 z_range bf_freq 100; ...
%                .20 0 z_range bf_freq 100];
           
source_info = [0 0 z_range bf_freq 100];
U = [25 50 0];

[p, Fs] = simulateArraydata(source_info, mic_pos, c, 10e3, 0.01, U);

[CSM, freqs] = developCSM(p.', bf_freq-5, bf_freq+5, Fs, size(p,2)/Fs, 0);
[X, Y, B] = FastBeamforming3Conv(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c, U);
% [X, Y, B] = CleanSCConv_mod(CSM, z_range, freqs, [x_range y_range], ...
%                              0.01, mic_pos.', c, U);
                         
%%

BB = 20*log10(sqrt(real(B))/2e-5/4/pi);
maxSPL = max(BB(:));
minSPL = min(BB(:));
imagesc(X,Y,BB);
title(['max: ' num2str(maxSPL) ' dB']);
axis equal; axis([x_range y_range]);
colorbar; caxis([maxSPL-dBrange maxSPL]);
axis xy;
