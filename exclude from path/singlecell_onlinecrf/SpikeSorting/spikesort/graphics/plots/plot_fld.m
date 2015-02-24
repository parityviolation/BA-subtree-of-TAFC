function [x1,x2,w,confusion] = plot_fld( spikes, c1, c2, show)

   if ~isfield(spikes,'waveforms'), error('No waveforms found in spikes object.'); end

hax = gca;
select1 = get_spike_indices(spikes, c1 );
select2 = get_spike_indices(spikes, c2 );
is_clusters = length(c1) == 1 & length(c2) == 1;

if is_clusters 
    color1 =  adjust_saturation( spikes.info.kmeans.colors(c1,:), .7); 
    color2 =  adjust_saturation( spikes.info.kmeans.colors(c2,:), .7 );
else
    color1 = [.1 .1 .9];
    color2 = [.9 .1 .1];
end

warning off backtrace
if nargin == 3, show = 1; end
cla(hax)

% get collection of waveforms using PCA
d = diag(spikes.info.pca.s);
r = find( cumsum(d)/sum(d) >.95,1);
r = min( r, min( length(select1), length(select2) ) );
w1 = spikes.waveforms( select1, :)* spikes.info.pca.v(:,1:r);
w2 = spikes.waveforms( select2, :)* spikes.info.pca.v(:,1:r);


% calcualte scatter matrices
S1 = cov(w1) * (size(w1,1)-1);
S2 = cov(w2) * (size(w2,1)-1);
Sw = S1 + S2;

% calculate FLD
w = inv(Sw)*( mean(w1)-mean(w2) )';


% project data
x1 = w' * w1';
x2 = w' * w2';
my_range = [ min( [x1 x2]) max([x1,x2]) ];
bins = linspace(my_range(1), my_range(2),100);
[n1,y1] = hist(x1,bins);
[n2,y2] = hist(x2,bins);

if ~show | spikes.params.display.show_gmm_overlap
  confusion  = gmm_overlap( w1,w2 );
else
    confusion = -1;
end

if show
    
    
    h1 = patch( [y1 fliplr(y1)],[n1 zeros(size(y1))], zeros(size([y1 y1])), color1);
    h2 = patch( [y2 fliplr(y2)],[n2 zeros(size(y2))], zeros(size([y1 y1])), color2);
    
     set([h1 h2],'LineWidth',.25,'FaceAlpha', 0.7);
     set(h1 , 'ButtonDownFcn', {@raise_band, h1 });        
     set(h2 , 'ButtonDownFcn', {@raise_band, h2 });        

     if is_clusters
       legend([h1 h2],{num2str(c1),num2str(c2)},'Location','Best')
     else
               legend([h1 h2],{'1st','2nd'},'Location','Best')
 
     end
      legend hide
     
    xlabel('Linear Discriminant')
    ylabel('No. of spikes')
    
    set(hax,'Tag','plot_fld');

        cmenu = uicontextmenu;
     item(1) = uimenu(cmenu, 'Label', 'Show legend', 'Callback',@toggle_legend, 'Tag','legend_option','Checked', get(legend,'Visible') );
     if is_clusters 
            item(3) = uimenu(cmenu, 'Label', 'Use cluster colors', 'Callback',{@recolor_fld,hax},'Separator','on','Checked','on' );
     end

    % save color info
    label1 = 'Group 1';
    label2 = 'Group 2';
    if is_clusters
        label1 = num2str(c1);
        label2  = num2str(c2);
        data.color1 = color1;
        data.color2 = color2;
        data.color_by_clusters = 1;
        data.h1= h1;
        data.h2 = h2;
        data.menu_item = item(3);
        set(hax,'UserData',data)
        
    end
        if ~any(confusion(:) == -1)
          title( ['MD Overlap: ' label1 ' = ' num2str( 100-100*confusion(1,1),'%2.1f' ) '%, ' label2 ' = ' num2str( 100-100*confusion(2,2),'%2.1f' ) '%'] );   
        end
            

    set(hax,'UIContextMenu',cmenu)
end
end

function recolor_fld( varargin )
 hax = varargin{end};
 data = get(hax,'UserData');
 
 if ~data.color_by_clusters
    color1 =  data.color1; 
    color2 =  data.color2;
    set(data.menu_item,'Checked','on');
else
    color1 = [.1 .1 .9];
    color2 = [.9 .1 .1];
    set(data.menu_item,'Checked','off');
 end
set(data.h1,'FaceColor',color1)
set(data.h2,'FaceColor',color2)

data.color_by_clusters = ~data.color_by_clusters;
set(hax,'UserData',data );
end

function toggle_legend( varargin )
    
    item = findobj( get(gca,'UIContextMenu'),'Tag', 'legend_option');
    
    if isequal( get(legend,'Visible'),'on')
       legend('hide'); set(item,'Checked','off');
   else
       legend('show'); set(item,'Checked','on');
   end
   

end

function word = bool2word( b )
    if b, word = 'on'; else,word='off';end
end
    
function color = adjust_saturation( color, new_sat )

    color = rgb2hsv( color );
    color(2) = new_sat;
    color = hsv2rgb(color);
end

    
    
    
