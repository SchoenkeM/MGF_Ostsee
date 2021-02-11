function initializeDigraph(obj)
    
    % Create a directed graph to show the progress of the overall
    % chronology/succession.
    %
    % Each track is a node in the graph.
    %
    % Each intersection where the top/bottom track relationship has been
    % picked is a directed edge in the graph pointing from the top node
    % (track) to the bottom node (track)
    
    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'updating graph ...')
    drawnow
    
    try
        delete(obj.GraphHandles)
    catch
        
    end
    
    row = 1;
    col = 3;
    
    % Focus on the intersections that have been looked at
    maskIsPicked    = obj.Intersections.Attributes{:,'isPicked'};
    trackIds        = obj.Intersections.Attributes{maskIsPicked,{'track','track_2'}};
    topTrack        = obj.Intersections.Attributes{maskIsPicked,'topTrack'};
    
    % Further focus on the relationships that have been decisively defined 
    maskHasEdge     = topTrack ~= 0;
    edge            = topTrack(maskHasEdge);
    tmp             = topTrack == trackIds; % find the bottom track id
    [r,c]           = find(~tmp & repmat(maskHasEdge,1,2));
    [r,ind]         = sort(r);
    c               = c(ind);
    edge(:,2)       = trackIds(sub2ind(size(trackIds),r,c));
    intersectionId  = obj.Intersections.Attributes{maskIsPicked,'intersection'}(maskHasEdge);
    
    % Create node table
    nodeNames       = unique(strtrim(cellstr(num2str(trackIds(:),'%u'))));
    NodeTable       = table(nodeNames,'VariableNames',{'Name'});
    
    if sum(maskIsPicked) == 0
        % Create digraph without edge and without nodes
        obj.Digraph     = digraph();
    elseif sum(maskHasEdge) == 0
        % Create digraph without edges, only nodes
        obj.Digraph  	= digraph(zeros(numel(NodeTable.Name)),NodeTable);
    else
        % Create edge table
        edgeStr         = reshape(strtrim(cellstr(num2str(edge(:),'%u'))),[],2);
        edgeName        = strtrim(cellstr(num2str(intersectionId(:),'%u')));
        EdgeTable       = table(edgeStr,edgeName,'VariableNames',{'EndNodes','Name'});

        % Create digraph with edges and nodes
        obj.Digraph   	= digraph(EdgeTable,NodeTable);
    end
    obj.GraphHandles    = plot(obj.AxesHandles(obj.AxesMeta.spi(row,col)),obj.Digraph);
    
    set(obj.GraphHandles,...
        'LineWidth',    1,...
        'NodeColor',    'k',...
        'EdgeColor',    'k')
    layout(obj.GraphHandles,'force')
    
	% Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end