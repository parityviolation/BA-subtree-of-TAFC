function stim = getStimCode(varargin)
% function stim = getstimCode(stimulusstruct,collapse_var)
% OR  function stim = getstimCode(expt,fileInd,collapse_var)
% INPUT: 
%         stimulusstruct should be expt.stimulus struct
%         collapse_var (optional) is the stim variable to collapse default to no collapse

% BA103010
if nargin==3 % INPUT: getstimCode(expt,fileInd,collapse_var)
    expt = varargin{1};
    fileInd = varargin{2};
    
    if isempty(fileInd)        
        stim.values = NaN;
        stim.code = NaN;
        return;
    end
    
    collapse_var = varargin{3};
    
    stimulusstruct = expt.stimulus(fileInd(1));
else % INPUT: getstimCode(stimulusstruct,collapse_var)
    stimulusstruct= varargin{1};
     collapse_var = varargin{2};
   if nargin<2, collapse_var = 0; end
end



varparam = stimulusstruct.varparam(1);
if length(stimulusstruct.varparam)>1
    varparam2 = stimulusstruct.varparam(2);
else collapse_var = 0; end

switch (collapse_var)
    case 1 % UNTESTED
        stim.type = varparam2.Name;
        stim.values = varparam2.Values;
        
        nCond_Varparam1 = length(varparam.Values);
        nCond_Varparam2 = length(varparam2.Values);
        
        for i = 1:nCond_Varparam1
            stim.code{i} = [i:nCond_Varparam2:nCond_Varparam2*nCond_Varparam1];
        end
        % TO DO
    case 2 % collapse var 2
        stim.type = varparam.Name;
        stim.values = varparam.Values;
        
        % Set stimulus code
        nCond_Varparam2 = length(varparam2.Values);
        temp = 1:nCond_Varparam2:nCond_Varparam2*length(stim.values);
        
        % can collapse a subset of all var2
            Varparam2_conds = [1:nCond_Varparam2]; % collapse all 
%             Varparam2_conds = [4]; % collpase subset  
        
        for i = 1:length(temp)
            stim.code{i} = [];
            for j = Varparam2_conds 
                stim.code{i} = [stim.code{i} temp(i)+Varparam2_conds-1]; % Assumes nCond_Varparam2 orientations at same constrast
            end            
        end
    otherwise % nothing collapsed
                stim.type = varparam.Name;
        stim.values = varparam.Values;

        for i = 1:length(stim.values)
            stim.code{i} = i;
        end
end