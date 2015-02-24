%% plot FS and RS units for a handful of unit*-s

ua_good_sub = ua_extrac([1:end]); % remove one unit with weird waveform   

color.rs = [0 0 0.8];
color.fs = [0.8 0 0];

params.figmargin = [0.08 0.1  0.05  0 ];  % [ LEFT RIGHT TOP BOTTOM]
params.cellmargin = [0.08 0.03  0.08  0.06 ];
 

h.fig = 6;
figure(h.fig);clf;
% orient(h.fig,'tall')
% plot waveforms
h.ax.wav = axes('Parent',h.fig);
h.ax.metric = axes('Parent',h.fig);
%position
hx = [h.ax.wav h.ax.metric];
setAxesOnaxesmatrix(hx,2,1,[],params)
defaultAxes(hx)

% add axis labels
xlabel(h.ax.metric,'trough to peak (ms)')
ylabel(h.ax.metric,'slope 0.5 ms post-trough')

ua_rs = filtUnitArray(ua_good_sub, 1, 'label', 'good unit');
[hwav hmetric]  = plotwave_helper(ua_rs,h.ax);
h.hl_wav.rs = hwav; h.hl_metric.rs = hmetric;
desc_str.rs = ua_unitDescription(ua_rs);

ua_fs = filtUnitArray(ua_good_sub, 1, 'label', 'FS good unit');
[hwav hmetric]  = plotwave_helper(ua_fs,h.ax);
h.hl_wav.fs = hwav; h.hl_metric.fs = hmetric;
desc_str.fs = ua_unitDescription(ua_fs);

if 0 
hleg = legend({desc_str.rs{:} desc_str.fs{:}},'Interpreter','none');
hleg_text = findobj(hleg,'type','text');
set(hleg_text,'FontSize',6)
end

 set( [h.hl_metric.fs  h.hl_metric.rs] ,'MarkerSize',30)
% add colors
fldn = fieldnames(h.hl_metric);
for i=1:length(fldn),
    set(h.hl_metric.(fldn{i}),'color',color.(fldn{i}))
    set(h.hl_wav.(fldn{i}),'color',color.(fldn{i}))
end

% set axis positions