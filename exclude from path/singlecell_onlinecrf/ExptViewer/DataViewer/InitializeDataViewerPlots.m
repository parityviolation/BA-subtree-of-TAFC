function handles = InitializeDataViewerPlots(handles)

% Get dvplot struct from DataViewer
dvplot = getappdata(handles.hDataViewer,'dvplot');
nPlotOn = numel(dvplot.pvOn);

% Compute axes positions
margins = [0.05 0.035 0.042 0.035];
axPos = dvAxesPosition(nPlotOn,margins);

% altColor = [0.25 0.75 0.25; 0.145 0.145 1];            	% green, blue
altColor = [0.4 0.4 0.4; 0.145 0.145 1];                    % gray, blue

try
    delete(handles.hPlotLines);
    delete(handles.hLabels);
    delete(handles.hThresh);
    delete(handles.hRaster);
end

% Get channel order
ChannelOrder = getappdata(handles.hDataViewer,'ChannelOrder');
Probe = getappdata(handles.hDataViewer,'Probe');


if isequal(length(ChannelOrder),length(dvplot.pvOn))
    % Adjust channel order
    k = ismember(ChannelOrder,dvplot.pvOn);
    pvOnOrdered = ChannelOrder(k);
else
    display('length of ChannelOrder does not match number of channels plotted')
    pvOnOrdered = dvplot.pvOn;
end
% BA initialize sliders to thresholds already determined
if isfield(handles,'expt') % Make compatible with DaqDataViewer
    Thresholds = handles.expt.sort.manualThresh;
end

for i = 1:nPlotOn
    k = pvOnOrdered(i);
    
    % Position and format axes
    hAxisTemp = handles.hAllAxes(k);
    set(hAxisTemp,'Position',axPos{i},'Visible','on','XLim',[0 handles.SweepDuration], ...
        'YColor',[0.85 0.85 0.85],'XColor',[0.85 0.85 0.85],'TickDir','in','FontSize',9,'YTickLabel',[], ...
        'XAxisLocation','bottom','TickLength',[0.003 0.01],'XTickLabel',[]);
    YTickLabel = get(hAxisTemp,'YTickLabel');
    XTickLabel = get(hAxisTemp,'XTickLabel');
    if i == nPlotOn
        set(hAxisTemp,'XColor',[0.5 0.5 0.5],'XTickMode','auto','YTickLabelMode','auto', ...
            'XTickLabelMode','auto','YColor',[0.5 0.5 0.5]);
        set(get(hAxisTemp,'YLabel'),'String','mV','Position',[-0.015 0.5],'Units','Normalized');
        set(get(hAxisTemp,'XLabel'),'String','sec');
    end
    
    % Generate lines and labels
    hPlotLines(k) = line([0 handles.SweepDuration],[-1 -1],'Parent',hAxisTemp,'Color',altColor(mod(i,2)+1,:));
    hRaster(k) = line([0 handles.SweepDuration],[1 1],'Parent',hAxisTemp,'Color',altColor(mod(i,2)+1,:),...
        'Marker','s','LineStyle','none','MarkerSize',2,'Visible','off','MarkerFaceColor',altColor(mod(i,2)+1,:));
    hLabels(k) = text('Parent',hAxisTemp,'String',handles.ChannelName(k),'Units','normalized', ...
        'Position',[1.03 0.5],'Color',altColor(mod(i,2)+1,:),'FontSize',8,'HorizontalAlignment','right');
    
    % Initialize slider line
    if isfield(handles,'expt')  % Make compatible with DaqDataViewer
        if ~isempty(Thresholds)
            yTemp = Thresholds(k);
        else
            if isTDTexpt(handles.expt)
                yTemp  = -33;
            else
                yTemp = -.06;
            end
        end
    else
        yTemp = -0.06;
    end
    
    hThresh(k) = line([0 handles.SweepDuration],[1 1].*yTemp,'Parent',hAxisTemp,'Color',[1 0.7 0.7],'LineStyle','-', ...
        'Visible','off');
    
    % If using tetrodes, color by tetrode
    if any(strcmp(Probe,{'16 Channel 2x2','16 Channel 4x1'}))
        if any(k == ChannelOrder(1:4) | k == ChannelOrder(9:12))
            set(hPlotLines(k),'Color',altColor(1,:));
            set(hRaster(k),'Color',altColor(1,:));
            set(hLabels(k),'Color',altColor(1,:));
        elseif any(k == ChannelOrder(5:8) | k == ChannelOrder(13:16))
            set(hPlotLines(k),'Color',altColor(2,:));
            set(hRaster(k),'Color',altColor(2,:));
            set(hLabels(k),'Color',altColor(2,:));
        end
    end
    
    % Position threshold sliders
    yLimTemp = get(hAxisTemp,'YLim');
    hSliderTemp = handles.hAllSliders(k);
    sliderPos = axPos{i};
    sliderPos = [0.005 sliderPos(2) 0.006 sliderPos(4)];
    set(handles.hAllSliders(k),'Visible','on','Position',sliderPos,...
        'BackgroundColor',[1 1 1]);   % 'Min',yLimTemp(1),'Max',yLimTemp(2)
    set(hSliderTemp,'BackgroundColor',[1 1 1],'Value',yTemp, ...
        'Min',-0.3,'Max',0.12,'Visible','off','SliderStep',[0.0025 0.1]);
end

% Update handles struct
handles.hPlotLines = hPlotLines;
handles.hLabels = hLabels;
handles.hRaster = hRaster;
handles.hThresh = hThresh;

% Link axes properties
handles.linkAxes = linkprop(handles.hAllAxes,'XLim');
key = 'graphics_linkprop';
setappdata(handles.hAllAxes(1),key,handles.linkAxes);           % Store link object in first axis

% Set handles for all figure objects in DataViewer appdata
setappdata(handles.hDataViewer,'handlesPlot',[handles.hAllAxes; handles.hPlotLines; handles.hRaster]);

guidata(handles.hDataViewer,handles);