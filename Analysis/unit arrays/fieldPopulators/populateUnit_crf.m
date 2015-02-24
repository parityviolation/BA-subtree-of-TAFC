function unit = populateUnit_crf(unit, curExpt, curTrodeSpikes,varargin)


% Get theta
contrast = unit.contValues';
wnames = {'stim'};

% Get response for stimulus window
fnames = {'r100','r0','c50','n','contrast','rate'}; % predefine fields
for j = 1:length(wnames)
    for icond = 1:2
        for ifield = 1:length(fnames), unit.crf.(wnames{j}).(fnames{ifield})(icond) = NaN; end
        unit.crf.(wnames{j}).hyper_ratioparams(:,icond) = [NaN NaN NaN NaN]';
    end
end
if isstruct(unit.contRates.mn) % contRates was not filled with rates.. this is interpretted as there are no rates
    for j = 1:length(wnames)
        if isfield(unit.contRates.mn,wnames{j})
            
            r = unit.contRates.mn.(wnames{j});
            
            %             % LED may have been used. If response + LED is similar, use average,
            %             % otherwise use response - LED.
            %             if size(r,2) > 1
            %                 mr = mean(r);
            %                 percentDiff = abs((mr(1)-mr(2))/mr(1));
            %                 if percentDiff <= 1
            %                     r = mean([r(:,1) r(:,2)],2);
            %                 end
            %             end
            %
            unit.crf.(wnames{j}).contrast= [];
            unit.crf.(wnames{j}).rate= [];
            for icond = 1:size(r,2)

                rr = [nanmean(unit.contRates.mn.spont(:,icond)); r(:,icond)]; % add spontaneous activity as 0 contrast
                cc= [0; contrast];
                rrfit = rr(~isnan(rr));
                ccfit = cc(~isnan(rr));
                if sum(isnan(rr))<3
                    fprintf('Contrast Fitting cell (%s),%d\n', unit.expt_name, icond);
                    [ ~, params ] = fitit('hyper_ratio',rrfit(:),...
                        [ 0 0.15 0 0 ], [], [ 2*max(rrfit) max(ccfit) 10 max(rrfit) ], ...
                        [0 1e-4 1e-4 5], ccfit(:) );
                else
                    params = [NaN NaN NaN NaN];
                end
                unit.crf.(wnames{j}).contrast(:,icond) = cc;
                unit.crf.(wnames{j}).rate(:,icond) = rr;
                unit.crf.(wnames{j}).hyper_ratioparams(:,icond) = params;
                if all(isfinite(params))
                    manyc = linspace(0,1);
                    rr = hyper_ratio(params,manyc);
                    unit.crf.(wnames{j}).r100(icond) = rr(end)-rr(1);
                    unit.crf.(wnames{j}).r0(icond) = rr(1);
                    [~,i50] = min( abs((rr-rr(1))-(rr(end)-rr(1))/2) );
                    unit.crf.(wnames{j}).c50 (icond) = manyc(i50);
                    unit.crf.(wnames{j}).n(icond) = params(3);
                    if 0 % debugging
                        fitc = logspace(-3,0,200);
                        line(cc,rrfit,'Linestyle','none','Marker','o','Markerfacecolor','k','color','k');
                        line(fitc,hyper_ratio(params,fitc),'color','k');
                    end
                end
            end
        end
    end
end

