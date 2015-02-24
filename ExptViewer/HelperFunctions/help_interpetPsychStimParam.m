function [VarParam Param] = help_interpetPsychStimParam(psychstimctrlparams)


% if exist('psychstimctrlparams') % 121509 new format is 1 struct rather than multiple variable
    fldnames = fieldnames(psychstimctrlparams);
    for i = 1:size(fldnames,1) % convert fields of struct into variables
        s = sprintf('%s = psychstimctrlparams.%s;',fldnames{i},fldnames{i});
        eval(s);
    end
% end
i=0;
if 1 % Var1Val>1
    i=i+1;
    if exist('Var1Str','var'),
    VarParam(i).Name = Var1Str{Var1Val};
    else  VarParam(i).Name = CurrentVar1Str; end
    variscircular = 0;
    if (Var1Val == 2) && (Start1 == 0) && (Stop1 == 360)
        variscircular = 1; % orientation
    end
    
    if LinLog1==1
        if variscircular
            VarParam(i).Values = linspace(Start1, Stop1, nSteps1+1);
            VarParam(i).Values = VarParam(i).Values(1:end-1);
        else
            VarParam(i).Values = linspace(Start1, Stop1, nSteps1);
        end
    else
        VarParam(i).Values = logspace(log10(Start1), log10(Stop1), nSteps1);
    end
    
    if Var2Val>1
        i = i+1;
        if exist('Var2Str','var'),
            VarParam(i).Name = Var2Str{Var2Val};
        else  VarParam(i).Name = CurrentVar2Str; end
        variscircular = 0;
        if (Var2Val == 2) && (Start2 == 0) && (Stop2 == 360)
            variscircular = 1; % orientation
        end
        
        if LinLog2==1
            if variscircular
                VarParam(i).Values = linspace(Start2, Stop2, nSteps2+1);
                VarParam(i).Values = VarParam(i).Values(1:end-1);
            else
                VarParam(i).Values = linspace(Start2, Stop2, nSteps2);
            end
        else
            VarParam(i).Values = logspace(log10(Start2), log10(Stop2), nSteps2);
        end
    end
end
if exist('StimulusStr','var'),  
    Param.StimulusName = StimulusStr{StimulusNum};
else
    Param.StimulusName = CurrentStimulusStr;
end

Param.StimDuration = Duration;
if blankbkgrnd
    Param.Baseline = WaitInterval;
else
    Param.Baseline =nan;
end
if exist('maskstr','var') % backward compatibility with files that doesn't have this param
    Param.Mask = maskstr{popmenuMask}(1:3);
elseif exist('popmenuMask','var')
    Param.Mask = popmenuMask;
end
if isstr(maskcenterx) % don't know why there are these 2 cases?
Param.MaskPossize = [ str2num(maskcenterx) str2num(maskcentery) str2num(maskradiusx) str2num(maskradiusy)];
else
  Param.MaskPossize = [ (maskcenterx) (maskcentery) (maskradiusx) (maskradiusy)];
end
  
if exist('freq','var') % backward compatibilyt with files that doesn't have this param
    Param.spfreq = unique(freq(:));
else
    Param.spfreq = unique(spfreq(:));
end
Param.tempFreq = unique(TempFreq(:));
Param.orient = unique(orient(:));
Param.contrast = unique(contrast(:));
Param.length = unique(length(:));
Param.speed = unique(speed(:));
Param.phase = unique(phase(:));
Param.positionXY  = [unique(positionX) unique(positionY)];
Param.blankbkgrnd  = blankbkgrnd;
Param.randomize  = randomize;
Param.squaregratings  = squaregratings;
if ~isempty(findstr(Param.StimulusName, 'Movies'))
    Param.MovieName = MovieName;
    Param.MovieMag = MovieMag;
    Param.MovieRate = MovieRate;
else
    Param.MovieName = [];
    Param.MovieMag = [];
    Param.MovieRate = [];
end
Param.blankstim  = blankstim;
Param.fullflicker  = FullFlicker;

Param.screensz  = [PixelsX PixelsY];
Param.screendist  = ScreenDist;

if popmenuMask==4 % BA added binary indicator of mask independent of type to make life easier
    Param.bMask =0;
else    Param.bMask =1;end


% String with SELECTED Extra bits of  information about stimulus
Param.sDescAdditional = '';
if squaregratings==1
    Param.sDescAdditional = sprintf('%sSq. Grat', Param.sDescAdditional);
end
Param.sDescAdditional = sprintf('%s Mask %s\n', Param.sDescAdditional,num2str(Param.Mask));

if max(size(unique(Param.spfreq)))==1
    Param.sDescAdditional = sprintf('%sSf %1.1f cpd\n', Param.sDescAdditional, Freq0);
end
if max(size(unique(Param.tempFreq )))==1
    Param.sDescAdditional = sprintf('%sTf %1.1f Hz\n', Param.sDescAdditional, TempFreq0);
end
if max(size(unique(Param.orient)))==1
    Param.sDescAdditional = sprintf('%s%1.0f Deg\n', Param.sDescAdditional, Orient0);
end

if exist('PreWaitInt','var') % backward compatibility with files that doesn't have this param
    Param.PreWaitInt = PreWaitInt;
end

if exist('WaitInterval','var') % backward compatibility with files that doesn't have this param
    Param.PostWaitInt = WaitInterval;
end
end