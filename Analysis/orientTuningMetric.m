function [OSI OSImod DSImod] = orientTuningMetric(r,theta)
% function [OSI OSImod DSImod] = orientTuningMetric(r,theta)
% INPUT
% r matrix of average response at each theta,
%       note: osi can be computed on multiple sets of data by providing
%       each as its own column
% theta - vector of same length as the nrows of r
%
% OUTPUT
%    where n is the number of columns in r
%    OSI = 1- circular variance (see ref below)
%    OSImod = % $$\frac{R_p- R_o}{R_p+ R_o}$$ % like Niell and Stryker (but
%    not fit)
%    DSImod = % $$\frac{R_p- R_{p+180}}{R_p+ R_{p+180}}$$ 
%    halfWidth  = at 1/sqrt(2) of R_p (see ref below for intuition)
%
% reference:
% see Ringach et al 2002 (http://www.jneurosci.org/cgi/reprint/22/13/5639)
%       Worgoter and Eysel 1987 (http://ucelinks.cdlib.org:8888/sfx_local?sid=google&auinit=F&aulas t=W%C3%B6rg%C3%B6tter&atitle=Quantitative+determination+of+orientational+and+directional+components+in+the+response+of+visual+cortical+cells+to+moving+stimuli&id=doi:10.1007/BF00354980&title=Biological+cybernetics&volume=57&issue=6&date=1987&spage=349&issn=0340-1200)
%       Swindale Matsubara Cynader 1986 (http://www.swindale.ecc.ubc.ca/Publications?action=AttachFile&do=get&target=surface_organization.pdf)

% treat each column as indep
if length(theta)~=size(r,1)
    error('there must be a theta for each row of r')
end
if isrowvector(theta), theta = theta'; end
ncol = size(r,2);

for icol = 1:ncol
    try
    response = r(:,icol);
    % orientation metric 1
    % Note Cris does this by fitting 2 gaussians at theta
                    % and theata+pi first
                    % Orientation selectivity
    % ylabel('$$\frac{R_p- R_o}{R_p+ R_o}$$','Interpreter','latex');
    temp = max(response); % could be moresponsee than 1 max
    indmax(1) = find(response==temp(1),1,'first');% index of max response
    ind = theta == mod(theta(indmax(1))+180,360);
    if any(ind)
        indmax(2) = find(ind);% index of max response
    end
    indmaxortho(1) = find(theta == mod(theta(indmax(1))+90,360)) ;
    ind = find(theta == mod(theta(indmax(1))-90,360));
    if any(ind)
        indmaxortho(end+1) = ind ;
    end
    if ~isempty(indmaxortho) % can only calculate this if spiking at 90deg from max has been measured
        Rpref = mean(response(indmax)) ;% sum of respones to same orientation opposite direction
        Rortho = mean(response(indmaxortho));
    else
        Rpref = NaN;
        Rortho  = NaN;
    end
    OSImod(icol) = (Rpref - Rortho)./(Rpref + Rortho)';
    
    % direction metric
    if ~isnan(OSImod(icol)) & length(indmax>1)
        Rprefmax = max(response(indmax)); % index of maximum response
        Rpref180 = min(response(indmax)); % index of response 180 deg from maximum response
        
        if Rprefmax==Rpref180;
            DSImod(icol) = 0;
        else
            DSImod(icol) = (Rprefmax - Rpref180)./(Rprefmax + Rpref180)';
            
        end
    else
        DSImod(icol) = NaN;
    end

     
    % orientation metric 2
    % see Ringach et al 2002 (http://www.jneurosci.org/cgi/reprint/22/13/5639)
    %       Worgoter and Eysel 1987 (http://ucelinks.cdlib.org:8888/sfx_local?sid=google&auinit=F&aulas t=W%C3%B6rg%C3%B6tter&atitle=Quantitative+determination+of+orientational+and+directional+components+in+the+response+of+visual+cortical+cells+to+moving+stimuli&id=doi:10.1007/BF00354980&title=Biological+cybernetics&volume=57&issue=6&date=1987&spage=349&issn=0340-1200)
    %       swindale matsubara cynader 1986     (http://www.swindale.ecc.ubc.ca/publications?action=attachfile&do=get&target=surface_organization.pdf)
    % not sure using nansum here is best. it may be better to let the
    % result just be nan
    OSI(icol) = sqrt(nansum(response.*sind(2*theta))^2+nansum(response.*cosd(2*theta))^2)/nansum(response)';
    catch me
        getReport(me)
        OSI(icol) = nan;
        OSImod(icol) = nan;
        DSImod(icol) = nan;
        
    end
%     NOTE OSI should be equivalent to = 1- cirular variance;
end
