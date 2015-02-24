function setColor(h,color)

for ih = 1:length(h)
    
    if ishandle(h(ih))
        ty =get(h(ih),'type');
        
        switch(ty)
            
            case 'patch'
                if isempty(strfind(get(h(ih),'Marker'),'none')) % for scatter plot hopefully does'nt break other shit
                    set(h(ih),'MarkerEdgeColor',color)
                else
                    set(h(ih),'FaceColor',color)
                    ec = get(h(ih),'EdgeColor');
                    if ~(strcmp(ec,'none'))
                        set(h(ih),'EdgeColor',color)
                    end
                end
            case 'line'
                set(h(ih),'Color',color)
            case 'hggroup'
                set(h(ih),'Color',color)
        end
    elseif isstruct(h(ih))
        fd = fieldnames(h(ih));
        for ifld = 1:length(fd)
            temphl  = h(ih).(fd{ifld});
            if ishandle(temphl)
                setColor(temphl,color);
            else
                error('not a handle')
            end
            
        end
    end
end
