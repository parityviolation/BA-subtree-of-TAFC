function summaryUnitFigure(expt,unitList,hFigs)%% -- create summary plots (this should be its own function
        % - layout
        clear hsum
        
        ncol = length(unitList);
        sname = sprintf('Unit Summary');
        % find existing figure
        hsum.fig = findobj('Name',sname);
        if ~isempty(hsum.fig)
            clf(hsum.fig);
        else
            
           hsum.fig = figure('Name',sname,'Position',[391          33        1271         947]);
        end
        
        % create plots: plot missing, plot stability, plot isi
        %   for iclust= 1:length(unitList)
        %       htemp(iclust).hmiss.ax = axes('Parent', hsum.fig);
        %       [j j j j htemp(iclust).hmiss.ax] = plot_detection_criterion(spikes,unitList(iclus));
        %       set(get(htemp(iclust).hmiss.ax,'Title'),'color',[0.15 0.15 0.15]);
        % %       htemp(iclust).hstab.ax = axes('Visible','off','Parent', hsum.fig);
        % %       [htemp(iclust).hstab.ax1 htemp(iclust).hstab.ax2] = plot_stability(spikes,unitList(iclus));
        %   end
        
        % spike waveform autocorrelation
        irow = 1;
        hsum.mat(irow).params.matpos =     [0 0 1 0.2];                % [left top width height]
        hsum.mat(irow).params.cellmargin = [0.005 0.005 0.0 0.01];        % [left right top bottom]
        hsum.mat(irow).params.figmargin =  [0.03 0.04  0.04 0.02];                % [left right top bottom]
        hsum.mat(irow).params.matmargin =  [0 0 0 0];                      % [left right top bottom]
        hsum.mat(irow).nrow = 1;
        hsum.mat(irow).h = [];
        for i = 1: length(hFigs),
            hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.avgwv.ax,hsum.fig);
        end
        hsum.mat(irow).ncol = ncol;
        hsum.mat(irow).xdist = 0.15;
        hsum.mat(irow).ydist = 0.1;
        irow = 2;
        % spikes overtime
        hsum.mat(irow).params.matpos =     [0 0.21 1 0.2];                % [left top width height]
        hsum.mat(irow).params.cellmargin = [0.05 0.045 0.0 0.01];        % [left right top bottom]
        hsum.mat(irow).params.figmargin =  [0.03 0.04  0.03 0.02];                % [left right top bottom]
        hsum.mat(irow).params.matmargin =  [0 0 0 0];                      % [left right top bottom]
        hsum.mat(irow).nrow = 1;
        hsum.mat(irow).h = [];
        for i = 1: length(hFigs),
            hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.autocorr.ax,hsum.fig);
            
            %       hsum.mat(irow).h(end+1) = htemp(i).hmiss.ax ;
            %       hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.frvt.ax,hsum.fig);
        end
        hsum.mat(irow).ncol = ncol;
        hsum.mat(irow).xdist = 0.15;
        hsum.mat(irow).ydist = 0.1;
        
        irow = 3;
        % PSTH
        hsum.mat(irow).params.matpos = [0 0.42 1 0.3];             % [left top width height]
        hsum.mat(irow).params.cellmargin = [0.05 0.045 0.0 0.01];        % [left right top bottom]
        hsum.mat(irow).params.figmargin =  [0.01 0.01  0.03 0.02];                % [left right top bottom]
        hsum.mat(irow).params.matmargin = [0 0 0 0];                      % [left right top bottom]
        hsum.mat(irow).nrow = 1;
        hsum.mat(irow).h = []; for i = 1: length(hFigs),  hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.allp.ax,hsum.fig); end
        hsum.mat(irow).ncol = ncol;
        hsum.mat(irow).xdist = 0.08;
        hsum.mat(irow).ydist = 0.06;
        
        % Tuning
        irow = 4;
        hsum.mat(irow).params.matpos = [0 0.7 1 0.3];             % [left top wmdth height]
        hsum.mat(irow).params.cellmargin = [0.05 0.045 0.0 0.01];        % [left right top bottom]
        hsum.mat(irow).params.figmargin =  [0.03 0.04  0.03 0.02];                % [left right top bottom]
        hsum.mat(irow).params.matmargin = [0 0 0 0];                      % [left right top bottom]
        hsum.mat(irow).nrow = 1;
        hsum.mat(irow).h = [];
        for i = 1: length(hFigs),
            if isfield(hFigs{i},'pol'), hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.pol.stim.ax,hsum.fig);
            elseif  isfield(hFigs{i},'cr')
                hsum.mat(irow).h(end+1) = copyobj(hFigs{i}.cr.ax,hsum.fig);
            end
        end
        hsum.mat(irow).ncol = ncol;
        hsum.mat(irow).xdist = 0.15;
        hsum.mat(irow).ydist = 0.1;
        set(cell2mat(get(hsum.mat(irow).h,'Title')),'Visible','Off')
        
        
        for i = 1:length(hsum.mat)
            try
            setaxesOnaxesmatrix(hsum.mat(i).h,hsum.mat(i).nrow,hsum.mat(i).ncol,[1:length(hsum.mat(i).h)],hsum.mat(i).params,hsum.fig);
            defaultAxes(hsum.mat(i).h, hsum.mat(i).xdist, hsum.mat(i).ydist);
            catch me, getReport(me); end
        end
        
        % add cluster name as title
        try
        for iclus = 1:length(unitList)
            s = sprintf('%s %s', hFigs{iclus}.unitTag, hFigs{iclus}.label);
            set(get(hsum.mat(1).h((iclus)),'Title'),'String',s,'interpreter','none');
        end
        
        catch me, getReport(me); end
        
        %  scale all waveforms on same scale
        hAwave = hsum.mat(1).h;
        if length(hAwave)>1,ylims = cell2mat(get(hAwave,'YLIM'));
        else ylims = get(hAwave,'YLIM'); end
        set(hAwave,'YLIM',[min(ylims(:,1)) max(ylims(:,2))])
        
        
        % --- Make info table
        genotype = expt.info.mouse.genotype;
        try
            if isfield(expt.info.transgene,'construct1')
                transgene = expt.info.transgene.construct1;
            elseif isfield(expt.info.transgene,'construct')
                transgene = expt.info.transgene.construct;
            end
        catch
            transgene = '';
        end
        exptInfo = strvcat(expt.name, [genotype ',' ' ' transgene]);
        hsum.textbox = annotation(hsum.fig,'textbox',[0.75 0.01 0.2 0.05],'String',exptInfo,...
            'EdgeColor','none','HorizontalAlignment','right','Interpreter',...
            'none','Color',[0.2 0.2 0.2],'FontSize',9,'FitBoxToText','on');
   
        set(hsum.fig,'Visible','on')
    end