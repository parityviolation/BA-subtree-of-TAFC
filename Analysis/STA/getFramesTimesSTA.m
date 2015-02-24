
function swdata = getFramesTimesSTA(PATH,STF,EFRAMES,chn)
% function swdata =  getFramesTimes(PATH,STF,EFRAMES,chn)
%
% INPUT
%   EFRAMES(optional) = expected number of frames
% function reads chn with frame info from daq (STF) and plots number
% of high-low transisions (should be frames) an their jitter
%
% outputs time of frame (defined as when values goes low)
% in struct swdata.frametime
% BA080409
bsave = 1;

r = RigDefs();
if nargin<4
    chn = 20; % channel with TTL frame information default
end

for m = 1:length(STF)
    
    savfn = sprintf('%s_frameTimes.mat',seperateFileExtension(getfilename(STF(m).filename)));
    savfn = fullfile(r.Dir.STA,'frameTimes',savfn);
    disp(savfn);
    
    % look for file
    if isempty(dir(savfn))
        LOADFILE = [PATH STF(m).filename];
        if length(STF(1).MAXTRIGGER)>1;  error('Length of MaxTrigger must be 1'); % not writtne for more than one trigger per trial TrigRange = [1 STF(m).MAXTRIGGER];
        else TrigRange = STF(1).MAXTRIGGER; end
        
        [data dt time] = loadDAQData(LOADFILE,chn,TrigRange);
        time = single(time);
        if m == 1, swlength = length(data)*dt;   end% sec
        
        temp = diff(data>max(data)/2);
        frame_sample = find(temp==-1);
        ind_fall = time(frame_sample);
        NFRAMES = length(ind_fall);
        
        
        if 0

            ind_rise = diff(find(temp==1)); % time between flip calls in stimulus presentation loop
            figure;  set(gcf,'Position',[ 1681         582         566         402])
            subplot(1,3,1);plot(temp*1000);
            title(['N_{fm}:' num2str(NFRAMES) '  T_{total} ' num2str(time(end)) 's'])
            xlabel('frames'); axis tight;
            ylabel('fm-fm time(ms)'); axis tight;
            
            subplot(1,3,2);hist(temp*1000,20)
            s= sprintf('HGRAM fm jitter\nmean min max\ncode+frame jitter: %s ms', num2str([mean(temp) min(temp) max(temp)]*1000));
            title(s);
            xlabel('ms'); axis tight;
            
            subplot(1,3,3); % to do place this on same axis as plottemp
            plot(time,data);      xlabel('s'); axis tight;
            title('raw signal');axis tight;
            
            temp2 = ind_fall((temp == max(temp))); % plot a red line at largest frame
            h=line([1 1].*temp2,[min(data) max(data)]);
            set(h,'color','r','linewidth',2);
            
            if length(ind_fall)==length(ind_rise)
                temp = ind_fall - ind_rise;
                subplot(1,4,3);
                hist(temp*1000,20);
                s = sprintf('mean min max\nframe time jitter: %s ms', num2str([mean(temp) min(temp) max(temp)]*1000));
                title(s);
                xlabel('ms')
            end
            
            clear ind_rise;
        end
        
        % Check right number of frames
        if ~isempty(EFRAMES)
            if EFRAMES ~= NFRAMES
                warning(['Wrong number of frames. Expected: ' num2str(EFRAMES) 'Actual: ' num2str(NFRAMES)])
            end
        end
        
        if bsave
            
            save(savfn,'data','ind_fall','frame_sample','STF','chn')
        end
    else
        disp(' *********** Loading STA movie frame times *************')
        
        load(savfn)
    end
    
    swdata(m).frametime = ind_fall;
    swdata(m).sample = frame_sample;
    
    %     % concatenate date from conseq files
    %     timeOfFrame(1+EFRAMES*(m-1):m*(EFRAMES))= [ind_fall+(m-1)*swlength];
    
    clear data time ind_fall temp;
end