function [posteriors, mle, map, ic95] = thatp(counts,genmo)
%THAT Naive Bayes-estimate of elapsed time from spike counts across a neural population.
%   [posteriors] = thatp(test set,likelihoods), where test set is a matrix
%   containing spike count data has dimmensions trials by time bins by
%   neurons, and likelihoods is the output of the sister function thatl.
%   Size of posteriors is [time bins (datum) by time bins (estimated) by
%   trials by neurons].

narginchk(2,2)
nargoutchk(1,4)
pseudounits = 0;
dimens = size(counts);
if numel(dimens)==2
    temp = counts;
    counts = nan([dimens 2]);
    counts(:,:,1) = temp;
    temp2 = genmo;
    genmo = nan([size(temp2) 2]);
    genmo(:,:,1) = temp2;
    dimens(3) = 1;
    pseudounits = 1; % Skips last unit, which is a pseudounit
end
posteriors = nan(dimens([2 2 1 3])); % [time, timehat, trial, neuron]
edges = 0:50; % Range of allowed spike counts

if nargout >= 2
    mle.max = nan(dimens(1:2));
    mle.cm = nan(dimens(1:2));
    mle.mat = nan(dimens([2 2 1]));
    if nargout >= 3
        map.max = nan(dimens(1:2)); % Takes previous timestep distribution as prior
        map.cm = nan(dimens(1:2));
        map.mat = nan(dimens([2 2 1]));
        if nargout >= 4
            ic95 = 'Hoje nao tem. Passa amanha.';
        end
    end
end

%% Action
for u = 1:size(counts,3)-pseudounits
    for tr = 1:size(counts,1) % trial
        for tb = 1:size(counts,2) % time bin
            ndx = counts(tr,tb,u) == edges;
            %             figure, plot(squeeze(likelihoods(ndx,:,u)))
            temp = squeeze(genmo(ndx,:,u));
            temp(temp<0) = 0;
            if isempty(temp) || std(temp) == 0
                temp = ones(1,size(genmo,2));
            end
            temp = temp/sum(temp);
            if any(temp==0,2)
                display oops
            else
                posteriors(tb,:,tr,u) = temp; % DANGER.
            end
            clear temp
        end
    end
end
trange = [1:size(counts,2)];
% X = nan(size(counts,1),size(counts,2),size(counts,2));
if nargout >= 2
    for tr = 1:size(counts,1) % trial
        for tb = 1:size(counts,2) % time bin
            temp = squeeze(posteriors(tb,:,tr,:))';
            temp = temp*(log(realmin)/log(min(temp(temp>0)))); % To avoid hitting Matlab's precision limit DANGER
            nanNdx = any(isnan(temp),2);
%             zeroNdx = any(temp==0,2);
            zeroNdx = false(size(nanNdx));
            if pseudounits == 0
                crossu = prod(temp(~nanNdx&~zeroNdx,:)); % Combined across units
            else
                crossu = temp(~nanNdx&~zeroNdx,:)';
            end
            crossu = crossu/sum(crossu);
            mle.mat(tb,:,tr) = crossu;
            
            if min(crossu(:)) < 0 || max(crossu(:)) > 1
                display 'Probabilities not between 0 and 1'
                return
            end            

            if sum(crossu==max(crossu)) > 1
                mle.max(tr,tb) = mean(trange(crossu==max(crossu)));
            else
                mle.max(tr,tb) = trange(crossu==max(crossu));
            end            
            mle.cm(tr,tb) = crossu*trange';
            
            
            if nargout>=3
                if tb==1
                    crosst = crossu;
                else
                    %crosst = prod([squeeze(map.mat(tb-1,:,tr));crossu]);
                    prior = normpdf(1:size(counts,2),map.max(tr,tb-1),10);
                    crosst = prod([prior;crossu]);
                end
                crosst = crosst/sum(crosst);
                map.mat(tb,:,tr) = crosst;
                
                if sum(crosst==max(crosst)) > 1
                    map.max(tr,tb) = mean(trange(crosst==max(crosst)));
                else
                    map.max(tr,tb) = trange(crosst==max(crosst));
                end
                map.cm(tr,tb) = crosst*trange';
            end
        end
    end
end

% if nargout >= 4
%     for tb = 1:size(counts,2) % time bin
%         for tr = 1:size(counts,1) % trial
%         end
%     end
% end
%% Debugging
% close all
% for u = 1:size(likelihoods,3)
% figure, imagesc(squeeze(likelihoods(:,:,u))), axis xy, ylim([1 20])
% end

end