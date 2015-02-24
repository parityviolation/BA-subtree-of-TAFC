function [h online_assigns waves] = onlineSpkSelection(dv,h,data,Fs,ind_spike)  
% function [h spikes] = onlineSpkSelection(dv,h,data,Fs,ind_spike)  
WOI = round([0.5 0.5]*1e-3*Fs);
xtime = (-WOI(1):WOI(2))'*1/Fs*1000;

    for ichn = 1:length(ind_spike) % for each channel ( COULD BE TRODE instead .. require ssome thought)
         h.nspikes = h.nspikes + length(ind_spike{ichn});
         online_assigns{ichn} = []; % default

        %% NOTE doesn support multiple channels
        if ~isempty(ind_spike{ichn})
            WEIRDOFFSET = 1;  % this is from an offset in dvProcessDisplay.m where the spieks are detected

            [waves skipped] = getWOI( data(:,ichn)' ,ind_spike{ichn}+WEIRDOFFSET,WOI);
%             if 1 % debugging
%                 figure(99);clf;
%                 plot(data(:,ichn)'); hold on;
%                 plot( ind_spike{ichn}'+100,0.2*ones(size(ind_spike{ichn})),'.r')
%             end
            if ~ isempty(waves)
            % get spike params (assume that spikes are already aligned
            extremum1 = waves(:,15); % at index of peak
            for iwav= 1: size(waves,1) % for each spike
                temp = peakfinder(waves(iwav,15+1:end), [], dv.Invert(ichn)*-1); % find NEXT min or max
                indextremum2(iwav) = temp(1); % take first peak
                extremum2(iwav) = waves(iwav,indextremum2(iwav));
                
            end
            if ~ishandle(h.hspkwavesFig) % initialize figure if it doesn't exit
                h  = initOnlineSpkSelect;
            end
            
                        
            % plot spike parameters            
            cla(h.hax_waveplot);
            line(repmat(xtime,1,size(waves,1)),waves','Color','b','Parent',h.hax_waveplot); % to do change to lines 
            xtemp = [get(h.hln_spkwaveParam(1),'Xdata') extremum1'];
            ytemp = [get(h.hln_spkwaveParam(1),'Ydata'),indextremum2*1/Fs];
            set(h.hln_spkwaveParam(1),'Xdata',xtemp,'Ydata',ytemp);
            set(h.hln_spkwaveParamCurrent(1),'Xdata',extremum1,'Ydata',indextremum2*1/Fs);
            ytemp2 = [get(h.hln_spkwaveParam(2),'Ydata'),extremum2]; % would probably be faster to just save the values
            set(h.hln_spkwaveParam(2),'Xdata',xtemp,'Ydata',ytemp2);
            set(h.hln_spkwaveParamCurrent(2),'Xdata',extremum1,'Ydata',extremum2);
            

            % note one inconsistency with the plotting here is that it is
            % independent from the spikes struct in DataViewerCallback
            % (here all the data accumulated in the SpikeWaves figure is
            % ploted, even if it isn't in the spikes struct)
            if isfield(h.spkSelection,'spkwaveParam')  % hacked way of checking if seleciton criteria exists
                iline = 1;% could have polygon for other lines on other spk paremter plots
                % returns definition of polygon for selection
                temp = h.spkSelection.spkwaveParam{iline};
                las_x = temp(:,1);las_y = temp(:,2);
                in=inpolygon(extremum1',indextremum2*1/Fs,las_x,las_y);
                
                indSel=find(in>0);
                % find the ALL the  selected  for plotting
                in=inpolygon(xtemp,ytemp,las_x,las_y);
                indSelAll=find(in>0);
                
            else indSel= [1:size(waves,1)]; indSelAll = [1:length(xtemp)];end % if no selection criteria then use all spikes

            % plot selected spikes
            line(repmat(xtime,1,length(indSel)),waves(indSel,:)','Color','g','Parent',h.hax_waveplot); % to do change to lines 
            set(h.hax_waveplot,'Xlim',[min(xtime) max(xtime)],'Ylim',[min(waves(:)) max(waves(:))]);
            set(h.spkSelection.hln_spkwaveParam(1),'Xdata',xtemp(indSelAll),'Ydata',ytemp(indSelAll));
            set(h.spkSelection.hln_spkwaveParam(2),'Xdata',xtemp(indSelAll),'Ydata',ytemp2(indSelAll));
            
%             temp = ind_spike{ichn};
           % determine the assigns for each spiketimes 
            temponline_assigns = zeros(size(ind_spike{ichn}));
            temponline_assigns(indSel) = 1;
            online_assigns{ichn} = temponline_assigns;
            
            % keep track of number spikes (may not be necessary if spikes
            % keeps all spikes
            h.spkSelection.nspikes = h.spkSelection.nspikes+length(indSel);
            end
        end
        
        % Note only supports 1 chn
        s = ['Nspikes: ' num2str(h.nspikes) ' ' num2str(h.spkSelection.nspikes)];
        set(get(h.hax_waveplot,'Title'),'String',s)
        
    end
    
    
