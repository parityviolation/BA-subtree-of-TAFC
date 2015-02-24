function unit = populateUnit_oriTuning(unit, curExpt, curTrodeSpikes,varargin)


% Get theta
theta = unit.oriTheta';

% Get response for stimulus window
if ~isstruct(unit.oriRates.mn) % oriRates was not filled with rates.. this is interpretted as there are no rates
    unit.tuningMetric.osi = [NaN];
    unit.tuningMetric.osiP = [NaN];
    unit.tuningMetric.dsiP = [NaN];
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
         
         
         if size(rtemp,2)>1 % for 2G fit
             % use first 2 conditions to fix prefferred direction
             rr_ctrl = rtemp(:,1); rr_opto = rtemp(:,2); % assume first condition is control (not critical here)
             rmerge = mean( [rr_ctrl*(rr_ctrl\rr_opto), rr_opto], 2 );
             parsmerge = fitori(theta,rrmerge);
             Dp = parsmerge(1); % fix the preferred direction
             if size(rtemp,2)>2
                 disp('more than 2 Ori conditions found, only first 2 used to fix prefferred direction of 2Gfit')
             end
         else
             Dp = NaN;
         end
         for icond = 1:size(rtemp,2)
             r = rtemp(:,icond);
                          [unit.oriTuning.2Gfit.osi(icond) unit.oriTuning.2Gfit.osiP(icond) unit.oriTuning.2Gfit.dsiP(icond)] ...
                 = orientTuningMetric(r,theta);

             %  get 2G fit
             params= fitori(theta,r,[],[Dp NaN NaN NaN NaN]);
             [Dp, Rp, Rn, Ro, sigma] = vecdeal(params);
             %
             unit.oriTuning.2Gfit.r(icond,:) = oritune( [Dp, Rp, Rn, Ro, sigma]);
             unit.oriTuning.2Gfit.Rp(icond) = Rp; %
             unit.oriTuning.2Gfit.Dp(icond) = Dp;
             unit.oriTuning.2Gfit.Rn(icond) = Rn; % Rp+180
             unit.oriTuning.2Gfit.Ro(icond) = Ro; % Rp +90
             unit.oriTuning.2Gfit.sigma(icond) = sigma;
             unit.oriTuning.2Gfit.hwhm(icond) = sqrt(log(2)*2)*sigma;
             
             %  check that orientTuningMetric gets the same result as
             % straight calculating with Rp and Rn
             [unit.oriTuning.2Gfit.osi(icond) unit.oriTuning.2Gfit.osiP(icond) unit.oriTuning.2Gfit.dsiP(icond)] ...
                 = orientTuningMetric(unit.oriTuning.2Gfit.r,theta);
             
             % align and normalize turning curve
             [Rp Rn Ro] = vecdeal(100*params(2:4)/Rp);

              unit.oriTuning.align_norm_2Gfit.r(icond,:) = oritune( [Dp, Rp, Rn, Ro, sigma]);
             unit.oriTuning.align_norm_2Gfit.Rp(icond) = Rp;
             unit.oriTuning.align_norm_2Gfit.Dp(icond) = 0;
             unit.oriTuning.align_norm_2Gfit.Rn(icond) = Rn;
             unit.oriTuning.align_norm_2Gfit.Ro(icond) = Ro;
             unit.oriTuning.align_norm_2Gfit.sigma(icond) = unit.oriTuning.2Gfit.sigma(icond);
             unit.oriTuning.align_norm_2Gfit.osi(icond) = unit.oriTuning.2Gfit.osi(icond);
             unit.oriTuning.align_norm_2Gfit.osiP(icond) = unit.oriTuning.2Gfit.osiP(icond);
             unit.oriTuning.align_norm_2Gfit.dsiP(icond) =  unit.oriTuning.2Gfit.dsiP(icond);
             
             % align raw data
             unit.oriTuning.raw.r(icond,:) = r;
             [unit.oriTuning.raw.osi(icond) unit.oriTuning.raw.osiP(icond) unit.oriTuning.raw.dsiP(icond)] ...
                 = orientTuningMetric(unit.oriTuning.raw.r,theta);
             oooo = [theta-360 theta theta+360];             rrr = [ r; r; r ]';
             Dp = 90;
             unit.oriTuning.raw.thetaalign = theta+Dp-90;
             unit.oriTuning.raw.ralign(icond,:) = interp1(oooo,rrr,thetaalign,'spline');
             unit.oriTuning.raw.ralignnorm(icond,:) = unit.oriTuning.raw.ralign(icond,:)/unit.oriTuning.2Gfit.Rp(icond) 
            
             
         end
    end
end

% ori.2Gfit
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



