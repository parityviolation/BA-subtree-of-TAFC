function UpdateDataViewer(handles)
% 
% INPUT
%   handles: This should be the DataViewer handles
%
%
%   Created: 4/5/10 - SRO
%   Modified:

% Get updated plot vectors from DataViewer appdata
dvplot = getappdata(handles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);

% Turn off plots and threshold objects
set(handles.hAllAxes(dvplot.pvOff),'Visible','off');
set(handles.hPlotLines(dvplot.pvOff),'Visible','off');
set(handles.hLabels(dvplot.pvOff),'Visible','off');
set(handles.hRaster(dvplot.rvOff),'Visible','off');
set(handles.hAllSliders(dvplot.rvOff),'Visible','off');
set(handles.hThresh(dvplot.rvOff),'Visible','off');

% Compute axes positions
margins = [0.05 0.035 0.042 0.035];
axPos = dvAxesPosition(nPlotOn,margins);

% altColor = [0.25 0.75 0.25; 0.145 0.145 1];                               % green, blue
altColor = [0.4 0.4 0.4; 0.145 0.145 1];                                    % gray, blue

% Get channel order
ChannelOrder = getappdata(handles.hDataViewer,'ChannelOrder');
Probe = getappdata(handles.hDataViewer,'Probe');

% Adjust channel order of visible plots and threshold objects
kv = ismember(ChannelOrder,dvplot.pvOn);
pvOnOrdered = ChannelOrder(kv);
RasterOn = ismember(pvOnOrdered,dvplot.rvOn);

for i = 1:nPlotOn
    k = pvOnOrdered(i);
    hAxisTemp = handles.hAllAxes(k);
    set(hAxisTemp,'Position',axPos{i},'Visible','on', ...
        'YColor',[0.85 0.85 0.85],'XColor',[0.85 0.85 0.85],'YTickLabel',[],'XTickLabel',[]);
    set(get(hAxisTemp,'YLabel'),'String',[]);
    set(get(hAxisTemp,'XLabel'),'String',[]);
    if i == nPlotOn         % Corresponds to bottom plot
        set(hAxisTemp,'XColor',[0.5 0.5 0.5],'YColor',[0.5 0.5 0.5],'XTickMode','auto', ...
            'YTickMode','auto','XTickLabelMode','auto','YTickLabelMode','auto');
        set(get(hAxisTemp,'YLabel'),'String','mV','Position',[-0.015 0.5],'Units','Normalized');
        set(get(hAxisTemp,'XLabel'),'String','sec');
    end
    set(handles.hPlotLines(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
    set(handles.hLabels(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
    if RasterOn(i) == 1
        set(handles.hThresh(k),'Visible','on');
        set(handles.hRaster(k),'Color',altColor(mod(i,2)+1,:),'Visible','on');
        yLimTemp = get(hAxisTemp,'YLim');
        sliderPos = axPos{i};
        sliderPos = [0.005 sliderPos(2) 0.009 sliderPos(4)];
        set(handles.hAllSliders(k),'Visible','on','Position',sliderPos,...
            'BackgroundColor',[1 1 1]);   % 'Min',yLimTemp(1),'Max',yLimTemp(2)
    end
    
    % Set trigger and photodiode to light gray
    if (k == 1 || k == 18)
        lightGray = [0.75 0.75 0.75];
        set(handles.hPlotLines(k),'Color',lightGray);
        set(handles.hRaster(k),'Color',lightGray);
        set(handles.hLabels(k),'Color',lightGray);
    end
    
    % If using tetrodes, color by tetrode
    if any(strcmp(Probe,{'16 Channel 2x2','16 Channel 4x1'}))
        if any(k == ChannelOrder(1:4) | k == ChannelOrder(9:12))
            set(handles.hPlotLines(k),'Color',altColor(1,:));
            set(handles.hRaster(k),'Color',altColor(1,:));
            set(handles.hLabels(k),'Color',altColor(1,:));
        elseif any(k == ChannelOrder(5:8) | k == ChannelOrder(13:16))
            set(handles.hPlotLines(k),'Color',altColor(2,:));
            set(handles.hRaster(k),'Color',altColor(2,:));
            set(handles.hLabels(k),'Color',altColor(2,:));
        end        
    end
end

guidata(handles.hDataViewer,handles)