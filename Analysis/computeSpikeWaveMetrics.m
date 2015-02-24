function waveform =  computeSpikeWaveMetrics(wv,Fs)
% function waveform =  computeSpikeWaveMetrics(wv,Fs)

% BA 11.2010

% Niell and Stryker metrics " the height of the positive peak relative to the initial negative
% trough, the time from the minimum of the initial trough to maximum of the following peak,
% and the slope of the waveform 0.5 ms after the initial trough.
% This third measure provided a proxy for the total duration of the slower positive peak,
% because our waveform sampling was not of sufficient duration to measure the entire return to baseline. "
% http://www.jneurosci.org/cgi/content/full/28/30/7520

time = [1:length(wv)]/Fs*1e3; % ms

realwv = wv;
realtime = time;

% spline waveform
spline_Fs = 100e3;
time_splined = min(time):(1/spline_Fs*1e3):max(time); % ms;
wv_splined = spline(time,wv,time_splined);


% % all the metrics will be computed on the splined waveform
wv = wv_splined;
time = time_splined;

% find trough
amp_trough = min(wv);
ind_trough = find(wv==amp_trough,1,'first');
amp_trough = range(wv(1:ind_trough));

% find - POST trough, peak and peak amplitude
wv_posttrough =wv(ind_trough:end); % get waveform after trough

if 0 % debug
    figure(1);clf;
    plot(time,wv,'-b'); hold all;
    plot(time_splined,wv_splined,'-r')
    axis on;
end

% set time 0 to trough
time = time - time(ind_trough);

% error if 0.5 ms after spike deson't exist
if(  time(end)<0.65)
    warning ('Spike Waveform must have > 0.55 ms after the trough to compute all metics')
    
    amp_trough =NaN;
    amp_pk = NaN;
    troughpkRatio = NaN;
    troughpkTime_samples = NaN;
    slope05 = NaN;
else
    amp_pk = max(wv_posttrough);
    ind_pk = find(wv_posttrough == amp_pk,1,'first')+ind_trough-1;
    
    % compute metrics
    troughpkRatio = amp_trough/amp_pk;
    troughpkTime_samples  = ind_pk-ind_trough;
    % slope 0.5 ms after trough ( corresponds to the negative slope after peak
    % of FS and the onward upward slope of the RS)
    % normalize amplitude to trough
    normwv = wv/min(wv)*-1; % so slope is independent of amplitude
    timeaftertrough =(time(ind_trough:end));
    ind05 = find(abs(timeaftertrough-0.6) == min(abs(timeaftertrough-0.6)),1,'first') + ind_trough-1;  % find index at 0.5 ms after trough
    slope05 =( normwv(ind05) - normwv(ind05-1))/(time(ind05)-time(ind05-1)); %calculate slope at this point
    
    if 0 % debug plotting
        mn = min( wv);
        mx = max( wv);
        
        figure(99);clf;
        plot(wv)
        line([1 1]*ind_trough, [mn mx],'Color','k')
        line([1 1]*ind_pk, [mn mx],'Color','b')
        line([1 1]*(ind05), [mn mx],'Color','r')
        title(num2str(slope05))
    end
end

% % just to recenter the time on 0 at the trough
% find trough  (all the reall metrics were computed on the splined data)
temp = min(realwv);
temp_ind_trough = find(realwv==temp,1,'first');
realtime = realtime - realtime(temp_ind_trough);


% output
waveform.amp_trough = amp_trough;
waveform.amp_pk_posttrough = amp_pk;
waveform.troughpeakratio = troughpkRatio;
waveform.troughpeaktime = troughpkTime_samples/spline_Fs*1e3; % ms
waveform.slope05 = slope05; % normalized units/ms
waveform.sptime = time; % ms
waveform.spavgwave_metrics = wv; % save the splined waveform that the metrics were computed on
waveform.time = realtime; % ms
waveform.avgwave_metrics = realwv; % save the splined waveform that the metrics were computed on


