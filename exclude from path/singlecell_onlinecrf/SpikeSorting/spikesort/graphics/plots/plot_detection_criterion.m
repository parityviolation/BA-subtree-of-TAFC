function [thresh_val,m,stdev,missing] = plot_detection_criterion(spikes,clus,display)

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end
   if length(nargin) < 3, display = 1; end
   
   
if display, cla, end;

bins = 75;

% need to consider multiple channels

a = get_spike_indices(spikes, clus );
    
waves = spikes.waveforms(a,:,:);
num_channels = size(waves,3);
num_samples  = size( waves,2);

% get minimum on each channel normalized by threshold
if  size(waves,1) == 1
    mins = -squeeze(min(waves,[],2))' ./ repmat( spikes.info.detect.thresh, length(a), 1 );
else
    mins = -squeeze(min(waves,[],2)) ./ repmat( spikes.info.detect.thresh, length(a), 1 );
end

% keep the val
thresh_val = min(mins');

% determine global minimum if there are multiple plots
my_min = min(thresh_val);
ax = findobj( gcf, 'Tag', 'detection_criterion' );
if ~isempty(ax)
    xlims = get(ax(1),'XLim');
    if xlims(1) < my_min
        global_min = xlims(1);
    else
        global_min = my_min;
        set(ax, 'XLim', [my_min 0])
    end
else
    global_min = my_min;
end



% keep the val
if num_channels > 1
    thresh_val = min(mins');
else
    thresh_val = mins;
end


mylims = linspace( global_min, -1, bins+1);
x = mylims +  (mylims(2) - mylims(1))/2;

% BA WHY DOES THIS decrease to -1?
% hack to fix this
if global_min> -1
     mylims = mylims(end:-1:1);
end
% BA
n = histc( thresh_val,mylims );

%if any(thresh_val>-1), warning('Some waveforms do not meet detection criterion.'); end


 if display
  hold on
  hh = bar(x,n,1.0);
  hold off
  set(hh,'EdgeColor',[0 0 0 ])
  set( gca,'XLim',[ global_min 0]);
 end

% superimpose gaussian
m = mode_guesser(thresh_val, .05);
[stdev,m] = stdev_guesser(thresh_val, n, x, m);

N = max( 2 * sum(thresh_val <= m), length(thresh_val));
a = linspace(global_min,0,200);
b = normpdf(a,m,stdev);
b = (b/sum(b))*N*(x(2)-x(1))/(a(2)-a(1));
l =line(a,b);
set(l,'Color',[1 0 0],'LineWidth',1.5)

missing = 1-normcdf( -1,m,stdev);

if display
 title( ['Estimated missing spikes: ' num2str(missing*100,'%2.1f') '%']);

    l = line([-1 -1], get(gca,'YLim' ) );
    set(l,'LineStyle','--','Color',[0 0 0],'LineWidth',2)
    axis tight
    set( gca,'XLim',[ global_min 0]);

    set(gca,'Tag','detection_criterion')

    xlabel('Detection metric')
    ylabel('No. of spikes')
end       

end

function [stdev,m] = stdev_guesser( thresh_val, n, x, m)

    init = sqrt( mean( (m-thresh_val(thresh_val<=m)).^2  ) );
    
    num = 20;
    st_guesses = linspace( init/2, init*2, num );
    m_guesses  = linspace( m-init,min(m+init,-1),num);
    for j = 1:length(m_guesses)
        for k = 1:length(st_guesses)
              b = normpdf(x,m_guesses(j),st_guesses(k));
              b = b *sum(n) / sum(b);
              error(j,k) = sum(abs(b(:)-n(:)));
        end        
    end
    [val,pos] = min(error(:));
    jpos = mod( pos, num ); if jpos == 0, jpos = num; end
    kpos = ceil(pos/num);
    
    stdev = st_guesses(kpos);
    m     = m_guesses(jpos);

end







