function rigDef = rigDefs()
% BVA
% OUTPUT
%   rigDef: Struct containing rig specific information 

%%% --- Enter rig specific values in right column --- %%%
% Computer IP addresses
rigDef.DAQPC_IP                            = '192.168.137.76';
rigDef.StimPC_IP                           = '192.168.137.1';
% User equipment
% rigDef.equipment.amp                       = 'tdt rx5';
% rigDef.equipment.adaptorName               = 'tdt'; 
% rigDef.equipment.daqboard                  = 'tdt'; 
rigDef.equipment.amp                       = 'AM4000';
rigDef.equipment.adaptorName               = 'nidaq'; 
rigDef.equipment.daqboard                  = 'PCIe-6363'; 
rigDef.equipment.board.ID                  = '1';
rigDef.equipment.board.device              = 'dev1';

% User ID (e.g. SRO for Shawn R. Olsen)
rigDef.User.ID                             = 'BVA_';
% Directories
rigDef.Dir.CodeRoot                        = 'C:\Users\Bassam\Documents\MATLAB\092010\';
rigDef.Dir.Icons                           = [rigDef.Dir.CodeRoot, 'GuiTools\Icons\'];
rigDef.Dir.Dataroot                        = 'C:\Users\Bassam\Documents\Data\';                       
rigDef.Dir.Data                            = [rigDef.Dir.Dataroot 'rawdata\'];                       
rigDef.Dir.DataFilt                        = [rigDef.Dir.Dataroot 'filtered\']; 
rigDef.Dir.Analyzed                        = [rigDef.Dir.Dataroot 'Analyzed\'];
rigDef.Dir.Spikes                          = [rigDef.Dir.Dataroot 'SortedSpikes\'];
% rigDef.Dir.Stimuli                         = 'C:\Documents and Settings\Bassam Atallah\My Documents\2ph VCData\Stimuli\';    
rigDef.Dir.Expt                            = [rigDef.Dir.Dataroot 'Experiments\'];    
rigDef.Dir.ExptTable                       = [rigDef.Dir.Dataroot 'ExptTable\'];    
rigDef.Dir.Settings                        = [rigDef.Dir.CodeRoot 'Settings\'];  
rigDef.Dir.VStimLog                        = [rigDef.Dir.CodeRoot 'Users\Bassam\Documents\Vstim\VStimLog'];
rigDef.Dir.FigOnline                       = [rigDef.Dir.Dataroot 'OnlineFigures\'];
rigDef.Dir.VstimMovies                     = [rigDef.Dir.CodeRoot 'Users\Bassam\Documents\Vstim\VstimConfig\movies\'];
rigDef.Dir.Fig                             = 'C:\Users\Bassam\Dropbox\Bassam\Mingshan DataAnalysis\BA';
% Making sure all the directories exist: (goes after all dirs)
% (N.B. network drives that are not accessible may take a very long time)

directories = fieldnames(rigDef.Dir);
missing = '';
for idx = 1:length(directories)
    fldname      = directories{idx};
    dirToCheck   = getfield(rigDef.Dir, fldname);    
     parentfolder(dirToCheck,1);
end
% End Directories

% Prefix for daq file save names
rigDef.SaveNamePrefix                      = rigDef.User.ID;            % Can enter your own string if you want.
% % Defaults for DaqController GUI
rigDef.Daq.TriggerMethod                   = 'HwDigital';%'HwAnalogChannel';
rigDef.Daq.HwDigitalTriggerSource          = 'PFI0';
rigDef.Daq.SweepLength                     = 4;                       % in seconds
rigDef.Daq.TriggerRepeat                   = 120;
rigDef.Daq.TriggerFcn                      = '@DataViewerCallback';     % Use '@DataViewerCallback' unless you've developed your own online plotting callback
rigDef.Daq.SamplesAcquiredFcn              = '@DataViewerSamplAcqCallback'; 
rigDef.Daq.SamplesAcquiredFcn              = '';
rigDef.Daq.TimerFcn                        = '';
rigDef.Daq.StopFcn                         = '';
rigDef.Daq.OnlinePlotting                  = 'DataViewer';              % Flag to generate DataViewer GUI
rigDef.Daq.SampleRate                      = 32000;
rigDef.Daq.Position                        = [0        880];                % Position of DaqController (2 element vector [left bottom] in pixels)
rigDef.Daq.Sca                         = [1250 600];                % Position of DaqController (2 element vector [left bottom] in pixels)
% Defaults values for DataViewer GUI
rigDef.DataViewer.Position                 =  [458    50   750   975];          % Position of DataViewer ([left bottom width height] in pixels)
rigDef.DataViewer.AnalysisButtons          = 1;
rigDef.DataViewer.UsePeakfinder            = 0;
% Default Position for Online Figures
rigDef.onlinePSTH.Position                 = [ 1224          52         208         975];
rigDef.onlinePSTHTuning.Position           = [  0    0   420   90];
rigDef.onlinePSTHTuning.axesmargins        = [0.2 0.01 0.042 0.035];
rigDef.onlinePSTH.axesmargins              = [0.2 0.01 0.042 0.035];
rigDef.onlineFR.Position                   = [  1448          52         216         975];
rigDef.onlineFR.windows                    = '{[0 0.5] [0.5 1.5] [1.6 2.5]}';
rigDef.onlineFR.axesmargins                = [0.2 0.01 0.042 0.035];
rigDef.onlineLFP.Position                  = [ 1679          52         233         975];
rigDef.onlineLFP.axesmargins               = [0.2 0.01 0.042 0.035];
rigDef.onlineCSD.Position                  = [2026         110         638         868];
rigDef.DataViewer.UsePeakfinder            = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for DAQ dataviewer
rigDef.DataViewer.ShowAllYAxes             = 1;                         % Default setting for whether to show all Y axes in DAQ dataviewer
rigDef.ExptDataViewer.ShowAllYAxes         = 0;                         % Default setting for whether to show all Y axes in EXPT dataviewer
rigDef.ExptDataViewer.UsePeakfinder        = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for EXPT dataviewer
rigDef.ExptDataViewer.DefaultThreshold     = 20;                      % Default threshold 
% Defaults for PlotChannel GUI
rigDef.PlotChooser.LPcutoff                = 200;                          
rigDef.PlotChooser.HPcutoff                = 200;
rigDef.PlotChooser.Position                = [0         485];                % Position of PlotChooser ([left bottom] in pixels)
rigDef.PlotChooser.chnsHP                       = [ 3]    ;  % default for plto chooser state                                                                                              
rigDef.PlotChooser.chnsThresh                   = [ 3]   ;                                                                                                 
% Defaults for ExptTable GUI
rigDef.ExptTable.Position                  = [ 0 400];        % Position of ExptTable  ([left bottom width height] in pixels)
rigDef.ExptTable.MarkPanel                 = 1;
% rigdef.ExptTable.TimeStrings               =
% rigDef.ExptTable.TimeStrings               % Defaults for ExptViewer GUI
rigDef.ExptViewer.Position                 = [1680         100];                 % Position of PlotChooser ([left bottom] in pixels)
rigDef.ExptViewer.UsePeakfinder            = 0;
% Defaults for probe
rigDef.Probe.Default                       = '16 Channel 1x16';          % Probe list in PlotChannel:  '16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode', 'Other'

rigDef.Probe.UserProbes                    = {'16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1' , '1x24poly' , '1x16poly' , 'BA 2Ph electrode'};
% Defaults for channel order
% NOTE, the indices here refer to the ORDER that of datacq of channels in AIOBJ 
% NOT the actual channel number
% number 
rigDef.ChannelOrder                        = {[[2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16 0]+1] ... % 2x2 (not corrected for digital setup)
    [[8 7 9 6 12 3 11 4 14 1 15 0 13 2 10 5 16 17 18]+1], ... % 1x16
    [1:16], ... % 1x4
    [17 16 19 23 18 9 24 15 8 19 7 14 6 20 5 13 4 21 3 12 2 22 1 11],... % 1x24 ( 1x 32 poly)
    [16 9 15 8 7 14 6 5 13 4 3 12 2 1 11 17 18 19],... % 1x16 ( 1x 32 poly)
    [1 2 3 4 5 7 -1 0 6]+2}; % BA 2Ph Glass electrode, 200A (bot),200A top, Ao4, Ao3, pd, flip

rigDef.equipment.board.numAnalogInputCh    = 19; % THIS SHOULD BE REMOVED or made to agree with daqplotchooser defaults
assert(rigDef.equipment.board.numAnalogInputCh > 1, 'Error: rigDef.equipment.board.numAnalogInputCh must be > 1.');

% LED defaults
rigDef.led.AIChan                          = {21,22}; % led chans on analog in
rigDef.led.Enable                          = 1;  % Enable (1), disable (0) LED GUI button

% anlogout defaults
rigDef.ao.Position                        = [7    46   589   422]; % not used (some weird problem window doesn't size right)
rigDef.ao.ID                              = {'ao0 - BLUE 473nm ', 'ao1 - AMBER 592nm', '1'}; % label for channels
% rigDef.ao.Enable                          = 1;  % Enable (1), disable (0) LED GUI button
rigDef.ao.Offset                          = {0,0,0};
rigDef.ao.HwChannel                       = {2,3,0}; % [ analog outs 0 1 2 3 
rigDef.ao.TriggerSourceList                  = {'PFI0','AIOBJ'}; % %'AIOBJ' or name of trigger channel or Manuale



% Defaults SpikeSorting
rigDef.SS.label_categories = {'in process', 'good unit', 'FS good unit', 'dirty unit', 'multi-unit', 'FS multi-unit', 'garbage'};
rigDef.SS.label_colors = [ .7 .7 .7; .3 .8 .3; .3 .3 .8;  .7 .5 .5; .6 .8 .6; .6 .6 .8; .5 .5 .5];
% (TO DO NEED TO CONVERT FROM normalized to pixels, not sure how to do this
% with 2 screensrigDef.SS.default_figure_size = [.05 .1 .9 .8]; 
     


% --- End of user-defined rig specific paramters --- %

% % Get nidaq board name
% if strcmp(rigDef.equipment.adaptorName,'nidaq')
%     temp = daqhwinfo('nidaq');
%     rigDef.equipment.daqboard = temp.BoardNames{1};  % Assume you only have board installed
% end

% Set DaqSetup parameters
fName = fullfile([rigDef.Dir.Settings 'DaqSetup\'],'DefaultDaqParameters.mat');
if isempty(dir(fName)) % make directory
    [junk pathname] = getFilename(fName);
    parentfolder(pathname,1);
    rigDef.Daq.Parameters = createDefaultDaqParameters(fName);   
else
    load(fName);
    rigDef.Daq.Parameters = Parameters;
end

% Set ExptTable parameters
if ~isfield(rigDef.ExptTable,'Parameters')
    fName = fullfile([rigDef.Dir.Settings 'ExptTable\'],'DefaultExptTable.mat');
    if isempty(dir(fName)) % make directory
        [junk pathname] = getFilename(fName);
        parentfolder(pathname,1);
        rigDef.ExptTable.Parameters  = createDefaultExptTable(fName);
        
    else
        load(fName);
        rigDef.ExptTable.Parameters = ExptTable;
    end
    
end
