function unit = populateUnit_osi(unit, curExpt, curTrodeSpikes,varargin)


% Get theta
theta = unit.oriTheta';

% Get response for stimulus window
if ~isstruct(unit.oriRates.mn) % oriRates was not filled with rates.. this is interpretted as there are no rates
    unit.osi = [NaN NaN];
else
    rtemp = unit.oriRates.mn.led +  unit.oriRates.mn.spont; 
    % BA don't subtract spontanous rate, it should  make no difference to the
    % tuning, and subtraction sometimes results in negative values which
    % screw up osi
    
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
        
        for icond = 1:size(rtemp,2)
            r = rtemp(:,icond);            
            % osi(1) = 1-circular variance, osi(2) = frac{R_p- R_o}{R_p+ R_o}
             [unit.osi(icond) unit.osiP(icond) unit.dsiP] = orientTuningMetric(r,theta);           
%             [unit.osi(icond)] = orientTuningMetric(r,theta);           
        end
    end
end