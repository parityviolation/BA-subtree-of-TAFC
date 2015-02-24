function rigDef = RigDefs()
%
% OUTPUT
%   RigDef: Struct containing rig specific information 

%%% --- Enter rig specific values in right column --- %%%
% Computer IP addresses
rigDef.DAQPC_IP                            = '132.239.203.32';
rigDef.StimPC_IP                           = '132.239.203.224';
% User equipment
% rigDef.equipment.amp                       = 'tdt rx5';
% rigDef.equipment.adaptorName               = 'tdt'; 
% rigDef.equipment.daqboard                  = 'tdt'; 
rigDef.equipment.amp                       = 'AM3600';
rigDef.equipment.adaptorName               = ''; 
rigDef.equipment.daqboard                  = 'PCIe-6259'; 
rigDef.equipment.board.ID                  = '1';
rigDef.equipment.board.numAnalogInputCh    = 21;
% User ID (e.g. SRO for Shawn R. Olsen)
rigDef.User.ID                             = 'BVA';
% Directories
rigDef.Dir.Data                            = 'F:\tank\';                       
% rigDef.Dir.Data                            = 'F:\VCData\';                       
rigDef.Dir.DataFilt                        = 'F:\VCData\filtered\'; 
rigDef.Dir.Analyzed                        = 'F:\VCData\Analyzed\';
rigDef.Dir.Spikes                          = 'F:\VCData\Analyzed\SortedSpikes\';
rigDef.Dir.Stimuli                         = 'F:\VCData\Stimuli\';    
rigDef.Dir.Expt                            = 'F:\VCData\Experiments\';    
rigDef.Dir.ExptTable                       = 'F:\VCData\ExptTable\';    
rigDef.Dir.Settings                        = 'F:\VCData\Settings\';  
rigDef.Dir.VStimLog                        = ['\\' rigDef.StimPC_IP '\My Documents\Matlab toolboxes\VStimLog\'];
rigDef.Dir.FigOnline                       = 'F:\VCData\Data\OnlineFigures\';
rigDef.Dir.Icons                           = 'C:\Documents and Settings\Bass\My Documents\MATLAB\MatlabCodeBase\GuiTools\Icons\'; 
% Prefix for daq file save names
rigDef.SaveNamePrefix                      = rigDef.User.ID;            % Can enter your own string if you want.
% Defaults for DaqController GUI
rigDef.Daq.SweepLength                     = 2.5;                       % in seconds
rigDef.Daq.TriggerRepeat                   = 48;
rigDef.Daq.TriggerFcn                      = '@DataViewerCallback';     % Use '@DataViewerCallback' unless you've developed your own online plotting callback
rigDef.Daq.SamplesAcquiredFcn              = '';
rigDef.Daq.TimerFcn                        = '';
rigDef.Daq.StopFcn                         = '';
rigDef.Daq.OnlinePlotting                  = 'DataViewer';              % Flag to generate DataViewer GUI
rigDef.Daq.SampleRate                      = 32000;
rigDef.Daq.Position                        = [1250 811];                % Position of DaqController (2 element vector [left bottom] in pixels)
% Defaults values for DataViewer GUI
rigDef.DataViewer.Position                 =  [0          34        1229         950];          % Position of DataViewer ([left bottom width height] in pixels)
rigDef.DataViewer.AnalysisButtons = 1;
% Default Position for Online Figures
rigDef.onlinePSTH.Position                 = [1417          29         160         719];
rigDef.onlinePSTH_Tuning.Position          = [1247          27         160         719];
rigDef.onlineFR.Position                   = [1417        -300         156         733];
rigDef.onlineLFP.Position                  = [1416        -516         156         733];
rigDef.onlineCSD.Position                  = [2026         110         638         868];
% Defaults for PlotChannel GUI
rigDef.PlotChooser.LPcutoff                = 200;                          
rigDef.PlotChooser.HPcutoff                = 200;
rigDef.PlotChooser.Position                = [1242         432];                % Position of PlotChooser ([left bottom] in pixels)
% Defaults for ExptTable GUI
rigDef.ExptTable.Position                  = [ 1242          34];        % Position of ExptTable  ([left bottom width height] in pixels)
rigDef.ExptTable.MarkPanel                 = 1;
% rigDef.ExptTable.TimeStrings               % Defaults for ExptViewer GUI
rigDef.ExptViewer.Position                 = [1680         100];                 % Position of PlotChooser ([left bottom] in pixels)
% Defaults for probe
rigDef.Probe.Default                       = '16 Channel 1x16';          % Probe list in PlotChannel:  '16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode', 'Other'

rigDef.Probe.UserProbes                    = {'16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode', 'Bass Glass electrode'};
% Defaults for channel order
% NOTE, the indices here refer to the ORDER that of datacq of channels in AIOBJ 
% NOT the actual channel number
% number 
rigDef.ChannelOrder                        = {[1:16], ... % 2x2
                                              [[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6 0 17 18 19 20]+1], ... % 1x16 
                                              [1:16], ... % 1x4
                                              [2 1 3 ],... % Glass electrode
                                              [3 5 6 1 2 4]}; % BASS Glass electrode
%                                               [2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16 0 17]+1 ... % 2x2
%                                               [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6 0 17]+1 ... % 1x16
%                                               [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14 0 17]+1 ... % 4x1
%                                              [14 11 6 3 13 12 5 4 8 1 16 9 7 2 15 10], ... % 1x16 BA (this converts tetrode order to linear probe order)
                                                                                                    
% LED defaults
rigDef.led.AIChan                          = {6}; % led chans on analog in
rigDef.led.Enable                          = 1;  % Enable (1), disable (0) LED GUI button

% anlogout defaults
rigDef.ao.ID                              = {'3', '2', '1'}; % label for channels
% rigDef.ao.Enable                          = 1;  % Enable (1), disable (0) LED GUI button
rigDef.ao.Offset                          = {0.9,0,0};
rigDef.ao.HwChannel                       = {3,2,1}; % [ analog outs 0 1 2 3 
rigDef.ao.TriggerSourceList                  = {'PFI0','AIOBJ'}; % %'AIOBJ' or name of trigger channel or Manual



% Defaults SpikeSorting
rigDef.SS.label_catagories = {'in process', 'good unit', 'FS good unit', 'dirty unit', 'multi-unit', 'FS multi-unit', 'garbage'};
rigDef.SS.label_colors = [ .7 .7 .7; .3 .8 .3; .3 .3 .8;  .7 .5 .5; .6 .8 .6; .6 .6 .8; .5 .5 .5];
% (TO DO NEED TO CONVERT FROM normalized to pixels, not sure how to do this
% with 2 screensrigDef.SS.default_figure_size = [.05 .1 .9 .8]; 
     


% --- End of user-defined rig specific paramters --- %

% Get nidaq board name
if strcmp(rigDef.equipment.adaptorName,'nidaq')
    temp = daqhwinfo('nidaq');
    rigDef.equipment.daqboard = temp.BoardNames{1};  % Assume you only have board installed
end

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
