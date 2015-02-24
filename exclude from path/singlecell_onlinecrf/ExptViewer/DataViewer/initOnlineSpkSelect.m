function h  = initOnlineSpkSelect
% function h  = initOnlineSpkSelect
rigdef = RigDefs;
h.hspkwavesFig = figure('Name','SpikeWaves','Position',[1683         581         545         399],...
    'Tag','OnlineSpikeSelect');
removeToolbarButtons(h.hspkwavesFig,[3 7 9:11 14])
% toolbar for selecting spikes
iconFile = fullfile(rigdef.Dir.Icons,'boxicon.mat');
hToolbar = findall(h.hspkwavesFig,'tag','FigureToolBar');
hpt = uipushtool(hToolbar,'CData',iconRead(iconFile),...
    'TooltipString','Select Parameter range',...
    'ClickedCallback',{@selectSpkParams_Callback,h});

% all spikes plots intialize
h.hax_waveplot = subplot(2,2,[1 2]); plotset(1)

h.hax_spkwaveParam(1) = subplot(2,2,3);  h.hln_spkwaveParam(1) = line(NaN,NaN); 
xlabel('peak1');            ylabel('peak-peak (ms)');
h.hax_spkwaveParam(2) = subplot(2,2,4);  h.hln_spkwaveParam(2) = line(NaN,NaN);  
xlabel('peak1');            ylabel('peak2');
set([h.hln_spkwaveParam],'Marker','o','LineStyle','none','Color','b')
% selected spikes intialize
h.spkSelection.hln_spkwaveParam(1) = line(NaN,NaN,'Parent',h.hax_spkwaveParam(1));
h.spkSelection.hln_spkwaveParam(2) = line(NaN,NaN,'Parent',h.hax_spkwaveParam(2));
set([h.spkSelection.hln_spkwaveParam],'Marker','o','LineStyle','none','Color','g')

h.hln_spkwaveParamCurrent(1) = line(NaN,NaN,'Parent',h.hax_spkwaveParam(1));
h.hln_spkwaveParamCurrent(2) = line(NaN,NaN,'Parent',h.hax_spkwaveParam(2));
set([h.hln_spkwaveParamCurrent],'Marker','o','LineStyle','none','Color','r')

h.nspikes = 0;
h.spkSelection.nspikes=0;
% Save guidata
guidata(h.hspkwavesFig,h); 