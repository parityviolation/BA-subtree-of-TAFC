function [thrConVec, slopeConVec, lConVec, uConVec] = settingParamsLLKFit(param, free_parameters, number_fits)
% function [thrConVec, slopeConVec, lConVec, uConVec] = settingParamsLLKFit(param, free_parameters, number_fits)
% helper function for LLKfitting, that ins
%
% BA adapted from Maria's code

switch (free_parameters)
    case 'none' % use the same model for all data
        thrConVec = param(1)*ones(number_fits,1);
        slopeConVec = param(2)*ones(number_fits,1);
        lConVec = param(3)*ones(number_fits,1);
        uConVec = param(4)*ones(number_fits,1);
    case 'all'
        % everything is changing
        thrConVec = param(1:number_fits);
        slopeConVec = param(number_fits+1:2*number_fits);
        lConVec = param(2*number_fits+1:3*number_fits);
        uConVec = param(3*number_fits+1:4*number_fits);
    case 'bias'
        % only thr changes across fits; slope, l and u are fit but are the same
        % for all fits
        thrConVec = param(1:number_fits);
        slopeConVec = repmat(param(number_fits+1),1,number_fits);
        lConVec = repmat(param(number_fits+2),1,number_fits);
        uConVec = repmat(param(number_fits+3),1,number_fits);
    case 'slope'
        % only slope changes across fits; thr, l and u are fit but are the same
        % for all fits
        thrConVec = repmat(param(1),1,number_fits);
        slopeConVec = param(2:number_fits+1);
        lConVec = repmat(param(number_fits+2),1,number_fits);
        uConVec = repmat(param(number_fits+3),1,number_fits);
        
    case 'l'
        thrConVec = repmat(param(1),1,number_fits);
        slopeConVec = repmat(param(2),1,number_fits);
        n = 2;
        lConVec = param(n:n+number_fits);
        uConVec = repmat(param(number_fits+3),1,number_fits);
    case 'u'
        thrConVec = repmat(param(1),1,number_fits);
        slopeConVec = repmat(param(2),1,number_fits);
        lConVec = repmat(param(3),1,number_fits);
        n =3;
        uConVec = param(n+1:n+number_fits);
    case 'lu'
        thrConVec = repmat(param(1),1,number_fits);
        slopeConVec = repmat(param(number_fits+1),1,number_fits);
        n = 2;
        lConVec = param(n:n+number_fits);
        n = 2 + 1*number_fits;
        uConVec = param(n:n+number_fits);
        
        case 'l slope'
         thrConVec = repmat(param(1),1,number_fits);
        slopeConVec = param(2:3);
        lConVec = param(4:2*number_fits+1);
        uConVec = repmat(param(2*number_fits+2),1,number_fits);
        case 'bias slope'
         thrConVec = param(1:number_fits);
        slopeConVec = param(number_fits+1:number_fits+2);
        lConVec = repmat(param(number_fits+3),1,number_fits);
        uConVec = repmat(param(number_fits+4),1,number_fits);
        case 'bias l'
         thrConVec = param(1:number_fits);
        slopeConVec = repmat(param(number_fits+1),1,number_fits);
        lConVec = param(4:2*number_fits+1);
        uConVec = repmat(param(number_fits+4),1,number_fits);
end
end

