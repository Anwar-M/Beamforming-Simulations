% Beamforming for various steering formulations according to Sarradj.
% XY and XZ planes.
%
%   Anwar Malgoezar, May 2018. 
%   Group ANCE

clearvars;
addpath('.\Program Files');

c = 343.2;
bf_freq = 3000;
x_range = 1/2*[-1 1];
y_range = 1/2*[-1 1];
z_bf = 1.0;
y_bf = 0;
z_range = 1/2*[-1 1] + z_bf;
res = 0.01;
dynamic_range = 25;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';
% mic_pos = 2*rand(15,2)-1; 
% mic_pos(:,3) = 0;

% source_info = [-0.3 0 z_bf bf_freq 100; ...
%                0.2 0 z_bf bf_freq 100];
           
source_info = [0 0 z_bf bf_freq 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c);
[CSM, freqs] = developCSM(p.', bf_freq-5, bf_freq+5, Fs, size(p,2)/Fs, 0);

[X1, Y1, B1] = FastBeamforming1(CSM, z_bf, freqs, [x_range y_range], ...
                             res, mic_pos.', c);
[X2, Y2, B2] = FastBeamforming2(CSM, z_bf, freqs, [x_range y_range], ...
                             res, mic_pos.', c);
[X3, Y3, B3] = FastBeamforming3(CSM, z_bf, freqs, [x_range y_range], ...
                             res, mic_pos.', c);
[X4, Y4, B4] = FastBeamforming4(CSM, z_bf, freqs, [x_range y_range], ...
                             res, mic_pos.', c);
                         
% To have XZ coords using FastBeamforming, we rotate the mic array and give
% an offset in z. To 'pretend' XY, we change coord mics nothing relative
% changes actually
[X1, Z1, B1z] = FastBeamforming1(CSM, y_bf, freqs, [x_range z_range], ...
                             res, [mic_pos(:,1) mic_pos(:,3) mic_pos(:,2)].', c);
[X2, Z2, B2z] = FastBeamforming2(CSM, y_bf, freqs, [x_range z_range], ...
                             res, [mic_pos(:,1) mic_pos(:,3) mic_pos(:,2)].', c);
[X3, Z3, B3z] = FastBeamforming3(CSM, y_bf, freqs, [x_range z_range], ...
                             res, [mic_pos(:,1) mic_pos(:,3) mic_pos(:,2)].', c);
[X4, Z4, B4z] = FastBeamforming4(CSM, y_bf, freqs, [x_range z_range], ...
                             res, [mic_pos(:,1) mic_pos(:,3) mic_pos(:,2)].', c);
                         
%%
% figure('Position', [65 220 1800 710]);
figure('Position', [10 60 1250 550]);
colormap('hot');

% XY plane

B1L = 20*log10(sqrt(real(B1))/2e-5);
subplot(2,4,1); imagesc(X1,Y1,B1L); 
doScatterSourceXY;
title('I'); ylabel('Y');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B1L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
    
B2L = 20*log10(sqrt(real(B2))/2e-5);
subplot(2,4,2); imagesc(X2,Y2,B2L);
doScatterSourceXY;
title('II');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B2L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B3L = 20*log10(sqrt(real(B3))/2e-5);
subplot(2,4,3); imagesc(X3,Y3,B3L);
doScatterSourceXY;
title('III');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B3L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B4L = 20*log10(sqrt(real(B4))/2e-5);
subplot(2,4,4); imagesc(X4,Y4,B4L);
doScatterSourceXY;
title('IV');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B4L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

% XZ plane

B1Lz = 20*log10(sqrt(real(B1z))/2e-5);
maxSPL = max(B1Lz(:));
subplot(2,4,5); imagesc(X1,Z1,B1Lz);
doScatterSourceXZ;
% contourf(X1, Z1, B1Lz, (round(maxSPL)-dynamic_range):3:round(maxSPL));
axis equal; axis([x_range z_range]);
ylabel('Z'); xlabel('X');
axis xy;
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
    
B2Lz = 20*log10(sqrt(real(B2z))/2e-5);
subplot(2,4,6); imagesc(X2,Z2,B2Lz);
doScatterSourceXZ;
axis equal; axis([x_range z_range]);
xlabel('X');
axis xy;
maxSPL = max(B2Lz(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B3Lz = 20*log10(sqrt(real(B3z))/2e-5);
subplot(2,4,7); imagesc(X3,Z3,B3Lz);
doScatterSourceXZ;
axis equal; axis([x_range z_range]);
xlabel('X');
axis xy;
maxSPL = max(B3Lz(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B4Lz = 20*log10(sqrt(real(B4z))/2e-5);
subplot(2,4,8); imagesc(X4,Z4,B4Lz);
doScatterSourceXZ;
axis equal; axis([x_range z_range]);
xlabel('X');
axis xy;
maxSPL = max(B4Lz(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);


