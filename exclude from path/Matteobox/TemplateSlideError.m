function ee = TemplateSlideError(rr,template)
% TemplateSlideError slides a template over a matrix and computes norm error
%
% ee = TemplateSlideError(rr,template), where rr is nt X nchans, and
% template is ns X nchans
%
% WARNUNG: does not attempt to rotate data by half a template...
%
% example:
% 
% rr = normrnd(0,1,100000,16);
% rr(1005, 1) =  100;
% rr(1005,16) = -100;
% 
% template = rr(1005:1020,:);
% ee = TemplateSlideError(rr,template);
% figure; plot(ee);
%
% 2009-04 Matteo Carandini and Neel Dhruv

[nt,nchans] = size(rr);

if size(template,2)~=nchans
    error('you made a mistake in sizes of rr and template');
end


ee = zeros(nt,nchans);
for ichan = 1:nchans
    ff = filter(flipud(template(:,ichan)),1,rr(:,ichan)   );
    gg = filter( ones(size(template,1),1),1,rr(:,ichan).^2);
    ee(:,ichan) = sum(template(:,ichan).^2)+gg-2*ff;
end
ee = sqrt(sum(ee,2));


