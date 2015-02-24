function waveform = MakeOutputWaveform(aoWavObj)
%
% INPUT
%   aoWavObj:
%
% OUTPUT
%   waveform:
%
%   Created: 2/10 - SRO
%   Modified: 7/5/10 - BA


Fs = aoWavObj.SampleRate;
Duration = aoWavObj.Duration;
NumSamples = aoWavObj.NumSamples;
Offset = aoWavObj.VoltageOffset;
FreqOsc = aoWavObj.Freq;
nPulses = aoWavObj.NumPulses;

%  REPLACE below with this code (REQUIRES TESTING

f = fieldnames(aoWavObj.CurrentIndex);
for ifdname = 1:length(f)
    afieldname = f{ifdname};
    currentindex = aoWavObj.CurrentIndex.(afieldname);
    tempparam = aoWavObj.(afieldname);
    s = sprintf('%s = %d' ,afieldname,tempparam(currentindex));
    evalc(s);
end

if isnan(Amplitude), Amplitude = 0 ; end
if isnan(TimeOffset), TimeOffset = 0 ; end
% Create output wavform
waveform = zeros(NumSamples,1);
switch aoWavObj.Output
    case 'on'
        
        switch aoWavObj.WaveformType
            case 'pulse train'
                
                if Width> 1/FreqOsc
                    warning('MAKEWAVEFORM: Pulses in a Train cannot have a Width > 1/Freq')
                    Width = 1/FreqOsc;
                end
                % make pulse.
                pulsewave = zeros(round((1/FreqOsc)*Fs),1,'single');
                pulsewave(1:Width*Fs) = (Amplitude-Offset);
                pulsewave(Width*Fs+1:end) = Offset;
                pulsewave = repmat(pulsewave,nPulses,1);
                
                StartPt = floor(TimeOffset*Fs) + 1;
                waveform(:) = Offset;
                ind = min((length(waveform)-StartPt +1),length(pulsewave));
                waveform(StartPt:StartPt+ind-1) = pulsewave(1:ind);
                
                
            case 'square'
                StartPt = round(TimeOffset*Fs) + 1;
                EndPt = StartPt + Width*Fs -1;
                waveform(StartPt:EndPt) = Amplitude;
                waveform = helperRepeat(waveform,StartPt,EndPt,nRepeat,RepeatDelay,Fs);
                
            case 'trapezoid'
                rampupTime  =  aoWavObj.rampup;
                rampdownTime  =  aoWavObj.rampdown;
                
                
                StartRampUpPt = round(TimeOffset*Fs) + 1;
                EndRampUpPt = max(StartRampUpPt + rampupTime*Fs -1,1); % must be at least 1
                
                StartPlateauPt = EndRampUpPt+1;
                EndPlateauPt = max(StartPlateauPt + Width*Fs -1,1);
                
                StartRampDownPt = EndPlateauPt+1;
                EndPtDownPt = max(StartRampDownPt + rampdownTime*Fs -1,1);
                
                
                % RAMP UP
                if rampupTime~=0
                    % y = mx + c
                    %                 where C is the offset voltage
                    
                    m = (Amplitude-Offset)/(EndRampUpPt-StartRampUpPt);
                    ind = StartRampUpPt:EndRampUpPt;
                    waveform(ind)  = Offset + m*[1:length(ind)];
                    
                    waveform(waveform>Amplitude) = Amplitude;  % Cap at trapezoid at amplitude (shouldn't be necassary)
                end
                
                % PLATEAU
                if Width~=0
                    waveform(StartPlateauPt:EndPlateauPt) = Amplitude;
                    
                end
                
                
                % RAMP DOWN
                if rampdownTime~=0
                    % y = mx + c
                    %                 where C is the offset voltage
                    
                    m = (Offset-Amplitude)/(EndPtDownPt-StartRampDownPt);
                    ind = StartRampDownPt:EndPtDownPt;
                    waveform(ind)  = Amplitude + m*[1:length(ind)];
                    
                end
                
                EndPt = EndPtDownPt;
                StartPt = StartRampUpPt;
                waveform(waveform<Offset) = Offset;  % Bottom at trapezoid at offset (shouldn't be necassary)

                waveform = helperRepeat(waveform,StartPt,EndPt,nRepeat,RepeatDelay,Fs);
            case 'sine'
                %                         w = 2*pi*freqOsc;
                %         data(end-length(t)+1:end) = OUTOFFSET + AMPLITUDE*sin(w*t)'; % not sure why offset is entirerange
                %     case 2 % triangle wave
                %         data(end-length(t)+1:end) = abs(rem(t,1/freqOsc)*freqOsc* AMPLITUDE - AMPLITUDE/2) + OUTOFFSET;
                %         %
                %     case 3 % sawtooth ("ramp")
                %         data(end-length(t)+1:end) = rem(t,1/freqOsc)*freqOsc* AMPLITUDE  + OUTOFFSET;
                
        end
        
    case 'off'
        waveform = zeros(NumSamples,1);
end

% set last sample to offset voltage (otherwise will stay one)
waveform(end) = Offset;


function waveform = helperRepeat(waveform,StartPt,EndPt,nRepeat,RepeatDelay,Fs)

% repeat waveform between startpt and endpt nRepeat times with a
% RepeatDelay between them
lengthWaveSamp = EndPt-StartPt;
RepeatDelaySamp = max(RepeatDelay*Fs -1,1);
tempStartPt = EndPt+RepeatDelaySamp;
for i = 1:nRepeat-1
    tempEndPt = min(tempStartPt + lengthWaveSamp,length(waveform));
    % catch case where tempStartPt - tempEndPt is smaller than the
    % repeated_waveform lenght (can happen if the repeats exceed the length
    % of the final waveform
    actuallengthWaveSamp = tempEndPt-tempStartPt;
    waveform(tempStartPt:tempEndPt)= waveform(StartPt:StartPt+actuallengthWaveSamp);
    
    tempStartPt =  tempEndPt+ RepeatDelaySamp;
end
