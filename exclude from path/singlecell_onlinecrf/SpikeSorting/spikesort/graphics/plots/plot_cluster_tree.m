function ax = plot_cluster_tree( spikes, clust)

    if ~isfield(spikes,'assigns'), error('No assignments found in spikes object.'); end

    colors = spikes.info.kmeans.colors;
    assigns = spikes.info.kmeans.assigns;
      
    tree = make_tree( assigns, clust, spikes.info.tree);
    tree = draw_everything( tree, colors, clust );
    
    data.agg_block = spikes.info.tree;
    data.tree = tree;
    data.assigns = assigns;   
    data.colors = colors;
    data.clust = clust;
    
    
    ax =gca;
    set(ax,'UserData',data,'Tag','cluster_tree');
    
function tree = draw_everything( tree, colors, clust );
    
    cla
    [junk tree] = draw_tree( tree, 1, colors );
    
    % prettify
    l = findobj(gca,'Type','line');
    set(l,'Color',[ 0 0 0],'LineWidth', 2)
    set( gca,'YLim',[-.5 max( 1,tree.order)*1.05], 'XLim',[.5 tree.num_nodes + .5])
    set(gca,'XTick',[])
    ylabel('Iteration when merged')
    xlabel(['Aggregation tree for cluster # ' num2str(clust)])
    uistack(l, 'bottom');
    
    
    
function [x,tree] = draw_tree( tree, first_time, colors )
    
    persistent pos;
    
    if first_time, pos = 1; end
      
    if ~isempty( tree.left )
        [x1 tree.left] = draw_tree( tree.left, 0, colors);
        [x2 tree.right] = draw_tree( tree.right, 0, colors);
        x = (x1 + x2) / 2;
%        y = tree.mean( [tree.num_members max(tree.left.num_members,tree.right.num_members)] );
        %y = tree.left.num_members+tree.right.num_members;
        y = tree.order;
        
        % draw lines
%        l(1) = line( [x x ], [y tree.num_members] );
        line( [x1 x2], [y, y] )
        l(2) = line( [x1 x1], [tree.left.order, y] );
        l(3) = line( [x2 x2], [tree.right.order, y] );
    
    else
        x = pos; pos = pos +1;
        hold on, s = scatter( x, tree.order ); hold off
        tree.dot = s;
        t = text(x + .1, tree.order, num2str(tree.local_id));
        set(t,'VerticalAlignment','bottom');
    end
    hold on, s = scatter( x, tree.order ); hold off
    tree.dot = s;
    set( s, 'MarkerFaceColor',  colors(tree.local_id,:), 'MarkerEdgeColor', colors(tree.local_id,:),'SizeData',60,'LineWidth',2 ) 
    
   
 
function [tree, val ] = make_tree( assigns, clust, agg_block)
    
    row = find( agg_block(:,1) == clust, 1,'last');
    tree.local_id = clust;
    
    if ~isempty(row)     
      from = agg_block(row,2); 
      agg_block(row:end,:) = [];
      [tree.left, left_val ] = make_tree( assigns, clust, agg_block );
      [tree.right,right_val] = make_tree( assigns, from, agg_block );
      tree.num_members = tree.left.num_members + tree.right.num_members;
      tree.num_nodes = tree.left.num_nodes + tree.right.num_nodes;
      tree.order = row;
     
      val = min( left_val, right_val );
      if right_val < left_val
          temp = tree.right;
          tree.right = tree.left;
          tree.left = temp;
      end      
      
    else
        tree.left = [];
        tree.right = [];
        tree.num_members  = sum( assigns == clust );
        tree.num_nodes    = 1;
        tree.order = 0;
        val = clust;
    end
   
    
    