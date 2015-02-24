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
TimeOffset = aoWavObj.TimeOffset;
Amplitude = aoWavObj.Amplitude;
Width = aoWavObj.Width;
FreqOsc = aoWavObj.Freq;
nPulses = aoWavObj.NumPulses;

if isnan(Amplitude), Amplitude = 0 ; end
% Create output wavform
waveform = zeros(NumSamples,1);
switch aoWavObj.Output
    case 'on'

        switch aoWavObj.WaveformType
            case 'pulse train'
                
                if Width> 1/FreqOsc
                    error('Pulses in a Train cannot have a Width > 1/Freq')
                end
                % make pulse.
                pulsewave = zeros((1/FreqOsc)*Fs,1,'single');
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
            case 'ramp'
                % Plateau
                StartPt = round(TimeOffset*Fs) + 1;
                EndPt = StartPt + Width*Fs -1;
                waveform(StartPt:EndPt) = Amplitude;   
                % Rising phase
                riseX = 1:StartPt-1;
%                 riseY = (Amplitude-Offset*0.95)*((riseX-1)/length(riseX))+Offset*0.95;
                riseY = (Amplitude-Offset)*((riseX-1)/length(riseX))+Offset; % BA removed 0.95 factor want direct control of Volrage
                waveform(riseX) = riseY;
                % Falling phase
                fallX = EndPt+1:length(waveform);
%                 fallY = (Amplitude-Offset*0.95)*(-(fallX-EndPt)/length(fallX)+1)+Offset*0.95;
                fallY = (Amplitude-Offset)*(-(fallX-EndPt)/length(fallX)+1)+Offset;
                waveform(fallX) = fallY;
            case 'sine'
        end
                   
    case 'off'
        waveform = zeros(NumSamples,1);
end
