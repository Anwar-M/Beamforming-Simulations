% The most basic beamforming. Generate simulated data, for single or
% multiple sources and perform conventional beamforming.
%

%   Anwar Malgoezar, April 2018. 
%   Group ANCE

clearvars;
addpath('.\Program Files');

c = 343.2;
bf_freq = 2000;
N_grid1D = 100;
x_range = 1*[-1 1];
y_range = 1*[-1 1];
z_range = 1.47;
dBrange = 12;

x_int = [-.25 .25];
y_int = [-.25 .25];

load('mic_poses_optim.mat');
mic_pos = mic_poses.';

source_info = [-.10 0 z_range bf_freq 100; ...
               .10 0 z_range bf_freq 100];
           
% source_info = [0 0 z_range bf_freq 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c);

[CSM, freqs] = developCSM(p.', bf_freq-5, bf_freq+5, Fs, size(p,2)/Fs, 0);

Value = SPIpoint(CSM, z_range, freqs, x_int, y_int, 0.1, mic_pos.', c);
disp(Value);

[X, Y, B] = FastBeamforming3(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);
                         
%%

BB = 20*log10(sqrt(real(B))/2e-5);
maxSPL = max(BB(:));
minSPL = min(BB(:));
imagesc(X,Y,BB);
title(['max: ' num2str(maxSPL) ' dB']);
axis equal; axis([x_range y_range]);
colorbar; caxis([maxSPL-dBrange maxSPL]);
axis xy;
