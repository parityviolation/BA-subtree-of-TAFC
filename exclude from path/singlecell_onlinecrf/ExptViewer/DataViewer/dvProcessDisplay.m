function [spiketimes ind_spike data] = dvProcessDisplay(dv,data,hDataViewer)
%
% INPUTS
%   dv:
%   data:
%
% OUTPUT
%
%
%   Created: 4/3/10 - SRO
%   Modified: 5/4/10 - SRO
% Get length of data
sizeData = length(data);

% Down-sample data
MaxPoints = 30000;
DownSampFactor = 3;
Fs = dv.Fs;
sizeData = length(data);
bDownSamp = 1;
if bDownSamp
    xtime = (1:DownSampFactor:sizeData)*1/Fs;       % sec
    [data Fs] = DownSamp(data,Fs,DownSampFactor);
else
    xtime = (1:1:sizeData)*1/Fs;
end

% % always LOW Pass at 5Khz % BA (kluge.. get rid of high freq noise)
% data = fftFilter(data,Fs,3000,1);

% Low-pass filter
if numel(dv.LPVectorOn) ~= 0
    data(:,dv.LPVectorOn) = fftFilter(data(:,dv.LPVectorOn),Fs,dv.LPCutoff(1),1);
end

% High-pass filter
if numel(dv.HPVectorOn) ~= 0
    data(:,dv.HPVectorOn) = fftFilter(data(:,dv.HPVectorOn),Fs,dv.HPCutoff(1),2);
    %     data(:,dv.HPVectorOn) = wavefilter(data(:,dv.HPVectorOn),5); %         takes 2-3 times as long but still only 200ms for 4sec
end

% Display data
for i = dv.PlotVectorOn'  % Must be row vector for this notation to work
    set(dv.hPlotLines(i),'XData',xtime,'YData',data(:,i));
end

% BA force no autoscaling on certain channs
i = 18;   set( get(dv.hPlotLines(i),'Parent'),'Ylim',[0 4]);

for i = [19:21]
   set( get(dv.hPlotLines(i),'Parent'),'Ylim',[0 10]);
end
% Make empty spiketimes array
spiketimes = cell(size(data,2),1);
ind_spike = spiketimes;
 WEIRDOFFSET = 1;  % this is from an offset in dvProcessDisplay.m 

% Using findpeaks function from Matlab Central
if numel(dv.RasterVectorOn) ~= 0
    
    for i = dv.RasterVectorOn'     % Must be row vector for this notation to work
        if 0
            Threshold = 3*dv.Thresholds(i);
            [ind_spike{i}] = peakfinder(data(WEIRDOFFSET:end-WEIRDOFFSET,i), Threshold, dv.Invert(i));
        else % hard threshold method
            [temp1 temp th_data] = thresh(data(WEIRDOFFSET:end-WEIRDOFFSET,i)*dv.Invert(i),dv.Thresholds(i),2);
            %note this peak finding is not quite right (see alignment if you plote detected events) not sure why
            [ind_spike{i}] = peakfinder(th_data.*data(WEIRDOFFSET:end-WEIRDOFFSET,i), [], dv.Invert(i)); % find trough of hard threshold detected psikes
            clear temp;
        end
        ind_spike{i} = ind_spike{i}+WEIRDOFFSET;
        
        loc = xtime(ind_spike{i});
        ylim = get(dv.hAllAxes(i),'YLim');
        pks = loc;
        pks(:) = ylim(2)*0.9;       % y-location of raster is set to 0.95*y-axis max
        set(dv.hRasters(i),'XData',loc,'YData',pks);
        
                % Set spiketimes
        spiketimes{i} = loc;


    end
    
end



