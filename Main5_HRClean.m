clearvars; %close all;
addpath('.\Program Files');

add_on_per = 0*1;
c = 343.2;
bf_freq = 100;
N_grid1D = 100;
x_range = 1*[-1 1];
y_range = 1*[-1 1];
z_range = 1;

D_ap = 1.9;
dynamic_range = 12;

load('mic_poses_optim.mat');
mic_pos = mic_poses.';

% source_info = [0.15 3*0.15 z_range 0*bf_freq 100; ...
%                -.15 -0.15 z_range 0*bf_freq 100];
source_info = [0 0 z_range bf_freq 100];
% source_info = [.15 0 z_range bf_freq-1 100; ...
%                -.15 0 z_range bf_freq+1 100];
% source_info = [.15 0 z_range bf_freq-1 100; ...
%                -.15 0 z_range bf_freq+1 100; ...
%                0 -0.5 z_range bf_freq-2 100];

[p, Fs] = simulateArraydata(source_info, mic_pos, c, 50e3, 10);

% [CSM, freqs] = developCSM(p.', bf_freq-1, bf_freq+1, Fs, size(p,2)/Fs, 0);
[CSM, freqs] = developCSM(p.', bf_freq-2, bf_freq+2, Fs, 0.5, 0.5, 0, 10);

[X1, Y1, B1] = FastBeamforming3(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);
[X3, Y3, B3] = HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c, 1, 0.25);
[X5, Y5, B5] = HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c, 1, 0.05);
[X6, Y6, B6] = HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c, 1, 0.75);
[X4, Y4, B4] = adaptive_HR_CleanSC_mod(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c, 1);
[X2, Y2, B2] = CleanSC(CSM, z_range, freqs, [x_range y_range], ...
                             0.01, mic_pos.', c);

if size(source_info,1) == 1
    Rf = z_range*tan(1.22*c/(bf_freq*2));
else
    Rf = 1.22*c/(D_ap*atan((source_info(1,1)-source_info(2,1))/z_range));
end

%%
% figure('Position', [65 220 1800 710]);
figure('Position', [10 60 1250 550]);
colormap('hot');

% XY plane

B1L = 20*log10(sqrt(real(B1))/2e-5);
subplot(2,4,1); imagesc(X1,Y1,B1L); 
doScatterSourceXY;
title('CB'); ylabel('Y');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B1L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
    
B2L = 20*log10(sqrt(real(B2))/2e-5/4/pi);
subplot(2,4,2); imagesc(X2,Y2,B2L);
% doScatterSourceXY;
title('SC');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B2L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B3L = 20*log10(sqrt(real(B3))/2e-5/4/pi);
subplot(2,4,3); imagesc(X3,Y3,B3L);
% doScatterSourceXY;
title('HR 0.25');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B3L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B4L = 20*log10(sqrt(real(B4))/2e-5/4/pi);
subplot(2,4,4); imagesc(X4,Y4,B4L);
% doScatterSourceXY;
title('AD.HR');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B4L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);


B5L = 20*log10(sqrt(real(B5))/2e-5/4/pi);
subplot(2,4,5); imagesc(X5,Y5,B5L);
% doScatterSourceXY;
title('HR 0.05');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B3L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

B6L = 20*log10(sqrt(real(B6))/2e-5/4/pi);
subplot(2,4,6); imagesc(X6,Y6,B6L);
% doScatterSourceXY;
title('HR 0.75');
axis equal; axis([x_range y_range]);
axis xy;
maxSPL = max(B3L(:));
colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);

% XZ plane

% B1Lz = 20*log10(sqrt(real(B1z))/2e-5);
% maxSPL = max(B1Lz(:));
% subplot(2,4,5); imagesc(X1,Z1,B1Lz);
% doScatterSourceXZ;
% % contourf(X1, Z1, B1Lz, (round(maxSPL)-dynamic_range):3:round(maxSPL));
% axis equal; axis([x_range z_range]);
% ylabel('Z'); xlabel('X');
% axis xy;
% colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
%     
% B2Lz = 20*log10(sqrt(real(B2z))/2e-5);
% subplot(2,4,6); imagesc(X2,Z2,B2Lz);
% doScatterSourceXZ;
% axis equal; axis([x_range z_range]);
% xlabel('X');
% axis xy;
% maxSPL = max(B2Lz(:));
% colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
% 
% B3Lz = 20*log10(sqrt(real(B3z))/2e-5);
% subplot(2,4,7); imagesc(X3,Z3,B3Lz);
% doScatterSourceXZ;
% axis equal; axis([x_range z_range]);
% xlabel('X');
% axis xy;
% maxSPL = max(B3Lz(:));
% colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);
% 
% B4Lz = 20*log10(sqrt(real(B4z))/2e-5);
% subplot(2,4,8); imagesc(X4,Z4,B4Lz);
% doScatterSourceXZ;
% axis equal; axis([x_range z_range]);
% xlabel('X');
% axis xy;
% maxSPL = max(B4Lz(:));
% colorbar; caxis([(maxSPL-dynamic_range) maxSPL]);


