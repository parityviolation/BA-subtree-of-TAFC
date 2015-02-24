function map = get_map_from_tree( tree, level )



    if tree.num_members < level | isempty(tree.left)
        map.to = tree.local_id;
        map.to_dot = tree.dot;
        map.from = unique( [tree.local_id append_me(tree.left,'local_id') append_me(tree.right,'local_id') ] );
        map.from_dot = [tree.dot append_me( tree.left, 'dot' ) append_me( tree.right,'dot') ];
        
    else
           map = [ get_map_from_tree( tree.left, level ), get_map_from_tree( tree.right, level ) ];
    end
end
     
function list = append_me( tree, fname )

        if isempty(tree)
            list = [];
        elseif ~isempty( tree.left )
            list = [ getfield(tree,fname) append_me(tree.left,fname) append_me(tree.right,fname) ];
        else
            list = getfield(tree,fname);
        end
end
