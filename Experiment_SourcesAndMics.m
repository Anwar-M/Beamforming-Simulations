%   This code allows to experiment beamforming by placing microphones and
%   sources with the mouse-clicks. The result of conventional beamforming 
%   is shown immediately after selection. At least 2 microphones are need 
%   to run the code.
%
%   For this code use is made of beamforming files found in '.\Program
%   Files'. 
%
%   Files used are:
%   - <simulateArrayData.m>
%   - <developCSM.m>
%   - <FastBeamforming3.m>
%

%   Anwar Malgoezar, Jan 2015. 
%   Group ANCE

function Experiment_SourcesAndMics
    redo = 1;
    while redo
        hFig = startSims;
        ButtonR = uicontrol('Parent',hFig,'Style','pushbutton','String','Reset','Units',...
            'normalized','Position', [0.45 0.05 0.05 0.08], 'Visible','on', ...
                              'Callback', 'uiresume(gcbf)'); 
        uiwait(hFig);
        if ishandle(hFig)
            close(hFig);
        else
            break;
        end
    end
end

function hFig = startSims

clearvars;
addpath('.\Program Files');

mic_x = [-1 1];
mic_y = [-1 1];
scan_x = [-1 1];
scan_y = [-1 1];
BF_dr = 12;

z_source = 1;
% bf_freq = 2000;
source_spl = 100;
c = 343;

reso = get(0,'screensize');
f2 = figure('Visible','on', 'Position',...
    [floor(reso(3)/2)-250, floor(reso(4)/2)-250, 600, 500], 'Resize','off');
ax = axes('position',[0.05 0.0417 0.75 0.9]);
box on; grid on;
title('Select mic by left-click, last mic by right-click');
axis([mic_x(1) mic_x(2) mic_y(1) mic_y(2)]);

% bSel = uicontrol('Parent',f2, 'style','push','Position', ...
%     [0.825*600 0.9*500 75 25],'String','Get Points','String', 'bla','Callback', '@isPressed');
% bSal = uicontrol('Parent',f2, 'style','push','Position',[0.825*600 0.8*500 75 25],'String','Salil','Callback', 'uiresume(gcbf)');
% uiwait(f2);

[xcfg, ycfg] = getpts(ax);

if numel(xcfg)==1
    close;
    error('Needs at least 2 microphones!');
end

cla;
title('Select sources by left-click, last source by right-click');
axis([scan_x(1) scan_x(2) scan_y(1) scan_y(2)]);
[source_x, source_y] = getpts(ax);

close(f2);

prompt = {'Frequency of source?'};
titlepr = 'Input';
dims = [1 20e3];
definput = {'2000'};
bf_freq_str = inputdlg(prompt,titlepr,1,definput);
bf_freq = str2double(bf_freq_str{1});

if isempty(bf_freq)
    error('Input must be a number!');
end

source_info = [source_x source_y z_source*ones(length(source_x),1) ...
               bf_freq*ones(length(source_x),1) ...
               source_spl*ones(length(source_x),1)];
mic_pos = [xcfg ycfg];
mic_pos(:,3) = 0;

[p, Fs] = simulateArraydata(source_info, mic_pos, c);
[CSM, freqs] = developCSM(p.', bf_freq-5, bf_freq+5, Fs, size(p,2)/Fs, 0);
[X, Y, B] = FastBeamforming3(CSM, z_source, freqs, [scan_x scan_y], ...
                             0.01, mic_pos.', c);
SPL = 20*log10(sqrt(real(B))/2e-5);

size_le_marker = 20;
reso = get(0, 'screensize');
f = figure('Visible', 'on', 'Position', ...
           [floor(reso(3)/2)-500, floor(reso(4)/2)-250, 1000, 500], ...
           'Resize', 'off');
       
MicsPositionFigure = axes;
title(MicsPositionFigure, 'Microphones');
hold(MicsPositionFigure);
set(MicsPositionFigure, ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on', ...
    'Position', [0.075 0.15 0.35 0.7], ...
    'XTick', mic_x(1):.5:mic_x(2), ...
    'YTick', mic_y(1):.5:mic_y(2), ...
    'XLim', mic_x, 'YLim', mic_y);

plot(MicsPositionFigure, xcfg, ycfg, 'k.', 'MarkerSize', size_le_marker);

BeamformFigure = axes;
hold(BeamformFigure);
set(BeamformFigure, ...
    'Box', 'on', 'XGrid', 'on', 'YGrid', 'on', ...
    'Position', [0.525 0.15 0.35 0.7], ...
    'XTick', scan_x(1):.5:scan_x(2), ...
    'YTick', scan_y(1):.5:scan_y(2), ...
    'XLim', scan_x, 'YLim', scan_y);
title(BeamformFigure, 'Beamforming');
text(gca, scan_x(2)/2, scan_y(1)-0.25, 'By Anwar Malgoezar, 2015');

maxSPL = ceil(max(SPL(:)));
contourf(X, Y, SPL, [(maxSPL-BF_dr):1:maxSPL], 'Parent', BeamformFigure);  %imagesc(X3,Z3,B3Lz);      
colormap('hot');
scatter(BeamformFigure, source_info(:,1), source_info(:,2), ...
    'kx', 'LineWidth', 1.5); 
cb = colorbar('peer', BeamformFigure, 'Position', [0.9 0.45 0.03 0.4], 'YTick', [(maxSPL-BF_dr):2:maxSPL]);
title(cb, 'SPL [dB]');
caxis([(maxSPL-BF_dr) maxSPL]);

hFig = f;

end

function isPressed(hObject,eventData)
  button_state = get(hObject,'Value');
end
