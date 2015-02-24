function spikes = spikes_collapseVarParam(spikes,varparam,nCollapse)
% function spikes = spikes_collapseVarParam(spikes,varparam,nCollapse)

% only deal with stim conditions where VarParams change ( don't include
% blanks which should have stimcond> nVar1 * nVar2

        spikes.stimcond = collapseVarParam(spikes.stimcond,varparam,nCollapse);
        spikes.sweeps.stimcond = collapseVarParam(spikes.sweeps.stimcond,varparam,nCollapse);        
