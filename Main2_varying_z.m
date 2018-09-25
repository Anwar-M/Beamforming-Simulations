% Animation of beamforming for various plane distances. See effect of
% beamforming when out-of-focus.
%
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
res = 0.01;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';
% mic_pos = 2*rand(15,2)-1; 
% mic_pos(:,3) = 0;

% source_info = [0 .05 z_range bf_freq 100; ...
%                0 -.15 z_range bf_freq 100];
           
source_info = [0 0 z_range bf_freq 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c);

zee = z_range-0.37*3:0.025:z_range+0.37*3;

B = zeros(numel(y_range(1):res:y_range(2)), ...
          numel(x_range(1):res:x_range(2)), numel(zee));

[CSM, freqs] = developCSM(p.', bf_freq, bf_freq, Fs, size(p,2)/Fs, 0);

for I = 1:numel(zee)
    fprintf('\tEvaluating BF at distance point %d/%d...\n', I, numel(zee));
    
    [X, Y, B(:,:,I)] = FastBeamforming3(CSM, zee(I), freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);
end
                         
%%
BB = 20*log10(sqrt(real(B))/2e-5);

maxSPL = max(BB(:));

for I = 1:numel(zee)
    imagesc(X,Y,BB(:,:,I));
    title(['z = ' num2str(zee(I)) ' m']);
    axis equal; axis([x_range y_range]);
    axis xy;
    colorbar; caxis([75 maxSPL]);
    pause(0.1);
end
