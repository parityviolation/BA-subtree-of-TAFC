function  spikes = fixLEDcond_helper(expt,spikes,condval)

% BA temp fix LED to be binary
if length(condval)<=2 && all(ismember(cell2mat(condval),[0 1]))
    %             spikes.led = 0; spikes.sweeps.led = 0; % make led binary % fix LED to be binary spikes.led = spikes.led>1; spikes.sweeps.led = spikes.sweeps.led>1; % make led binary
    
    if isfield(spikes,'bled')
        spikes.led = spikes.bled; spikes.sweeps.led = spikes.sweeps.bled; % make led binary % fix LED to be binary spikes.led = spikes.led>1; spikes.sweeps.led = spikes.sweeps.led>1; % make led binary
        disp([expt.name ': ********** USING bled **************'])
    else
        
        spikes.led = spikes.led>0.95; spikes.sweeps.led = spikes.sweeps.led>0.95; % make led binary % fix LED to be binary spikes.led = spikes.led>1; spikes.sweeps.led = spikes.sweeps.led>1; % make led binary
    end
else
    standardvalues =cell2mat(condval);
%     d = diff(cell2mat(condval(2:end)))
%     win = [0 0.05];% volts
%     for i=2:length(condval)-1
%         if i>2,        temp = condval{i-1}- d(i-2)*0.49;
%         else        temp = 0.051;    end
%         
%         if (i+1)<=length(condval), temp2 = condval{i+1}- d(i)*0.49;
%         else temp2 =  condval{i} + d(i-1)*0.49;end
%         win(i,:) = [max(temp,condval{i} + d(i-1)*0.49)  min(temp,condval{i} + d(i-1)*0.49)];
%         
%         end
% win = [0 0.049
%        0.055 0.07
%        0.075 0.085
%        0.09 0.11];
win = [0 0.049
       0.05 0.05
       0.1 0.1
       0.15 0.15
       0.2 0.2
       0.4 0.4
       0.5 0.5
       0.7 0.7
       0.8 0.8];
  
   spikes.sweeps.led = stardardizeLEDamp(spikes.sweeps.led,standardvalues,win);
        spikes.led = stardardizeLEDamp(spikes.led,standardvalues,win);
end