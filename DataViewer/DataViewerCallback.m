function DataViewerCallback(obj,event,hDataViewer)
% hDataViewer is the handle to the DataViewer GUI. This handle is used to
% access appdata stored in the DataViewer.
%

%   Created: 1/10 - SRO
%   Modifed: 4/5/10 - SRO

% Get information about AIOBJ (aka obj)
Trigger = obj.TriggersExecuted;
% disp(['---- DataViewerCallback.m: TriggerNum = ', num2str(Trigger), ' .']);

TriggerRepeat = obj.TriggerRepeat;
LoggingMode = obj.LoggingMode;
LogFileName = obj.LogFileName;
SamplesPerTrigger = obj.SamplesPerTrigger;

% Print SaveName to command line
if strcmp(LoggingMode,'Disk&Memory') && Trigger == 1
    LogFileName(1:end-4)
end

% Get stimulus information
global DIOBJ
% Reads digital ports and SAVES the result
stimconds = readDigitalPorts(DIOBJ,Trigger,TriggerRepeat,LoggingMode,LogFileName);
setappdata(hDataViewer, 'StimCondData', stimconds);

GetVStimFileName_Params(Trigger,LoggingMode,LogFileName,hDataViewer);


bLED = getappdata(hDataViewer,'bLED');
if bLED
    % obtains the LED condition and SAVES it
    try ledconds = GetLEDCond; catch ME, getReport(ME); end
    
else
    ledconds = nan(2,1);
end
setappdata(hDataViewer, 'LEDCondData', ledconds);



% --- Subfunctions --- %

function vstimParams = GetVStimFileName_Params(Trigger,LoggingMode,LogFileName,hDataViewer)
% Get name of stimulus and save to file

params = [];
if Trigger == 1 ;
    global UDP_OBJ_STIM_PC % UDP object connecting to stimulus PC
    try
        temp = fscanf(UDP_OBJ_STIM_PC); % NOTE: timeout is set when declaring UDP object
        if  ~isempty(temp)
            temp = strread(temp,'%s','delimiter','*'); % Stimulus filename
            
            
            S = fscanf(UDP_OBJ_STIM_PC);
            [splits, splits, splits, splits, splits, splits, splits]  = regexp(S,'\n'); %delimiter
            %parse to get COMMAND
            % cmd= splits{1,1}; % first line contains command
            
            params = rc_udprecieveParams(splits(2:end));
            
        end
    catch
        temp = []; params = [];
        warning('Failed to communicate with VSTIMPC via udp')
        
    end
    if ~isempty(temp)
        params.sfilename = temp{1};
        params.condName = temp{2};
        temp = LogFileName;
        if strcmp(LoggingMode,'Disk&Memory')
            save([temp(1:end-4) '_SFile'],'params');
        end
    end
    
    % save to DataViewer parameters
    vstimParams =params;
    
else
    vstimParams = [];
end
% get visual stimulus parameters
bflagLoadStim = 0;
if ~isempty(vstimParams)
    try
        [vstim.VarParam vstim.Param] = help_interpetPsychStimParam(vstimParams);
        setappdata(hDataViewer,'vstim',vstim);
        vstim.VarParam
    catch ME
        bflagLoadStim = 1;
        getReport(ME)
    end
    
end
if bflagLoadStim
    %     display('Loading Existing Vstim Parameters')
    
    vstim = getappdata(hDataViewer,'vstim');
    if isempty(vstim)
        vstim.VarParam.Values = 1;
        vstim.VarParam.Name = '';
        vstim.Param.blankstim = 0;
        display('No Vstim Parameters Exist');
    end
end

function params = rc_udprecieveParams(splits)
% recieves data from rc_udpsendParams in the form of a string and converts
% it back into a struct
try
    for i = 1:size(splits,2)-1
        % NOTE, right now can't send matrixes, or anything (e.g. substructs, cells) that is not a string
        % or a vector
        
        stemp= splits{1,i};
        ind = regexp(stemp,'\s'); ind = ind(1);
        params.(stemp(1:ind-1)) = stemp(ind+1:end);
        
        if ~any(isletter(params.(stemp(1:ind-1)))) % if not a string convert to vector
            params.(stemp(1:ind-1)) = str2num(params.(stemp(1:ind-1)));
        end
    end
    
catch
    i
end
