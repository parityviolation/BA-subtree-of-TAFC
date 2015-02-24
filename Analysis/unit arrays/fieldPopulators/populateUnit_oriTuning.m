function unit = populateUnit_oriTuning(unit, curExpt, curTrodeSpikes,varargin)


% Get theta
theta = unit.oriTheta';

% Get response for stimulus window
if ~isstruct(unit.oriRates.mn) % oriRates was not filled with rates.. this is interpretted as there are no rates
    unit.oriTuning = NaN;
    %     unit.tuningMetric.osi = [NaN];
else
    %     if isfield(unit.oriRates.mn,'led') % this shouldn't be necessary use
    %     .stim for everything
    %         rtemp = unit.oriRates.mn.led;
    %     else
    rtemp = unit.oriRates.mn.stim ;
    %     end
    
    if 0
        % LED may have been used. If response + LED is similar, use average,
        % otherwise use response - LED.
        if size(rtemp,2) > 1
            mr = mean(rtemp);
            percentDiff = abs((mr(1)-mr(2))/mr(1));
            if percentDiff > 1
                r = rtemp(:,1);
            else
                r = mean([rtemp(:,1) rtemp(:,2)],2);
            end
        end
    else
        
        
        if size(rtemp,2)>1 && all(isfinite(nanmean(rtemp(:,2)))) % for 2G fit
            % use first 2 conditions to fix prefferred direction
            rr_ctrl = rtemp(:,1); rr_opto = rtemp(:,2); % assume first condition is control (not critical here)
            rr_opto(isnan(rr_opto)) = 1; % remove nans
            rr_ctrl(isnan(rr_ctrl)) = 0;
            rmerge = nanmean( [rr_ctrl*(rr_ctrl\rr_opto), rr_opto], 2 );
            parsmerge = fitori(theta,rmerge);
            Dp = parsmerge(1); % fix the preferred direction
            if size(rtemp,2)>2
                disp('more than 2 Ori conditions found, only first 2 used to fix prefferred direction of 2Gfit')
            end
        else
            Dp = NaN;
        end
        
        for icond = 1:2 % pre declare fields assuming 2 conditions
            fieldn = {'Rp','Dp','Rn','Ro','sigma','hwhm','osi','osiP','dsiP','osiP_Rpref','dsiP_Rpref'};
            for ifield = 1:length(fieldn)
                unit.oriTuning.G2fit.(fieldn{ifield})(icond) = NaN;
                unit.oriTuning.align_norm_G2fit.(fieldn{ifield})(icond) = NaN;
            end
            unit.oriTuning.G2fit.r(:,icond) = nan(size(theta));
            unit.oriTuning.align_norm_G2fit.r(:,icond) = nan(size(theta));
            unit.oriTuning.raw.ralign(:,icond) = nan(size(theta));
            unit.oriTuning.raw.ralignnorm(:,icond) = nan(size(theta));
            unit.oriTuning.G2fit.orituneparams = nan(5,2); % reinitialize            
            unit.oriTuning.align_norm_G2fit.orituneparams =nan(5,2);  % reinitialize
            
        end
            
        for icond = 1:size(rtemp,2)

            r = rtemp(:,icond);
            unit.oriTuning.raw.r(:,icond) = r;
            [unit.oriTuning.raw.osi(icond) unit.oriTuning.raw.osiP(icond) unit.oriTuning.raw.dsiP(icond)] ...
                = orientTuningMetric(unit.oriTuning.raw.r(:,icond),theta);
            % remove NaNs
            fitr = r(~isnan(r));
            fittheta = theta(~isnan(r)); 
            
            if sum(isnan(r))<=3 % arbitrary limit on number of allowable NaNs
                %  get 2G fit
                params= fitori(fittheta,fitr,[],[Dp NaN NaN NaN NaN]);
                [Dp, Rp, Rn, Ro, sigma] = vecdeal(params);
                if icond==1, Rmaxctrl = Rp +Ro; end % assume first column is control and use to normalize everything
                % % note that because the fits are not perfect, the
                % normalization doesn't result in control curves all being
                % 100% at the peak. We will live with this (one might argue
                % it is better to use the fit than the data as the data
                % might miss the peak response)
                
                % % BA SHOULD have metric of quality of G2 fit
                unit.oriTuning.G2fit.orituneparams(:,icond) = params';
                unit.oriTuning.G2fit.r(:,icond) = oritune( [Dp, Rp, Rn, Ro, sigma],theta);
                unit.oriTuning.G2fit.Rp(icond) = Rp; %
                unit.oriTuning.G2fit.Dp(icond) = Dp;
                unit.oriTuning.G2fit.Rn(icond) = Rn; % Rp+180
                unit.oriTuning.G2fit.Ro(icond) = Ro; % Rp +90
                unit.oriTuning.G2fit.sigma(icond) = sigma;
                unit.oriTuning.G2fit.hwhm(icond) = sqrt(log(2)*2)*sigma;
                Rpref = oritune( params,Dp);
                Rortho = oritune( params,Dp+90);
                Rpref_180 = oritune( params,Dp+180);
                unit.oriTuning.G2fit.Rpref(icond) = Rpref;
                unit.oriTuning.G2fit.Rortho(icond) = Rortho;
                unit.oriTuning.G2fit.Rpref_180(icond) = Rpref_180;

                
                [unit.oriTuning.G2fit.osi(icond) unit.oriTuning.G2fit.osiP(icond) unit.oriTuning.G2fit.dsiP(icond)] ...
                    = orientTuningMetric(oritune( [Dp, Rp, Rn, Ro, sigma],[0:360]'),[0:360]');
                %  Note orientTuningMetric does NOT get the same result as
                %  just using (Rp - Ro)/(Rp + Ro) because ...
                % Rp is actually  already Rp -  Ro (because Ro is the offset in the G2 fit).
                % However, Ro can be negative which complicates things, i.e.
                % one can't just calculate it as Rp/(Rp + Ro) because not always < 1
                unit.oriTuning.G2fit.osiP_Rpref(icond) = (mean([Rpref Rpref_180]))/(mean([Rpref Rpref_180])+Rortho);
                unit.oriTuning.G2fit.dsiP_Rpref(icond) = (Rpref-Rpref_180)/(Rpref+ Rpref_180);
                
                % align and normalize turning curve ( to control)
                [Rp Rn Ro] = vecdeal(100*params(2:4)/Rmaxctrl);
                
                unit.oriTuning.align_norm_G2fit.r(:,icond) = oritune( [0, Rp, Rn, Ro, sigma],theta);
                unit.oriTuning.align_norm_G2fit.Rp(icond) = Rp;
                unit.oriTuning.align_norm_G2fit.Dp(icond) = 0;
                unit.oriTuning.align_norm_G2fit.Rn(icond) = Rn;
                unit.oriTuning.align_norm_G2fit.Ro(icond) = Ro;
                unit.oriTuning.align_norm_G2fit.sigma(icond) = unit.oriTuning.G2fit.sigma(icond);
                params = [unit.oriTuning.align_norm_G2fit.Dp(icond),...
                    unit.oriTuning.align_norm_G2fit.Rp(icond),...
                    unit.oriTuning.align_norm_G2fit.Rn(icond),...
                    unit.oriTuning.align_norm_G2fit.Ro(icond),...
                    unit.oriTuning.align_norm_G2fit.sigma(icond)];
                unit.oriTuning.align_norm_G2fit.orituneparams(:,icond)= params';               
                Rpref = oritune( params,0);
                Rortho = oritune( params,0+90);
                Rpref_180 = oritune( params,0+180);
                unit.oriTuning.align_norm_G2fit.Rpref(icond) = Rpref;
                unit.oriTuning.align_norm_G2fit.Rortho(icond) = Rortho;
                unit.oriTuning.align_norm_G2fit.Rpref_180(icond) = Rpref_180;
                % get raw data metrics and align
                oooo = [theta-360; theta; theta+360];             rrr = [ r; r; r ]';
                thetaalign = theta+Dp-90;
%                 NOTE: this spline interpolation can result in very small
%                 (0.01Hz typically) negative numbers. not sure why but
%                 doesn't seem to really mater)
                unit.oriTuning.raw.ralign(:,icond) = interp1(oooo,rrr,thetaalign,'spline');
                unit.oriTuning.raw.ralignnorm(:,icond)= unit.oriTuning.raw.ralign(:,icond)/Rmaxctrl*100;
           
            end
        end
    end
end
% ori.G2fit
% .fitresponse
% .normfitresponse
%    .raw
%          .oriIcirc
%          .oriI
%          .dirI
%          .Rp
%          .Rp180
%          .Rp90
%
% oriraw



