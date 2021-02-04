function initializeDigraph(obj)
    
    % Create a directed graph to show the progress of the overall
    % chronology/succession.
    %
    % Each track is a node in the graph.
    %
    % Each intersection where the top/bottom track relationship has been
    % picked is a directed edge in the graph pointing from the top node
    % (track) to the bottom node (track)
    try
        delete(obj.GraphHandles)
    catch
        
    end
    
    % Focus on the intersections that have been looked at
    maskIsPicked    = obj.Intersections.Attributes{:,'isPicked'};
    if sum(maskIsPicked) == 0
        obj.Digraph         = digraph();
        obj.GraphHandles    = plot(obj.AxesHandles(obj.AxesMeta.spi(2,3)),obj.Digraph);
        return
    end
    trackIds        = obj.Intersections.Attributes{maskIsPicked,{'track','track_2'}};
    topTrack        = obj.Intersections.Attributes{maskIsPicked,'topTrack'};
    
    % Further focus on the relationships that have been decisively defined 
    maskHasEdge     = topTrack ~= 0;
    edge            = topTrack(maskHasEdge);
    tmp             = topTrack == trackIds; % find the bottom track id
    
    edge(:,2)       = trackIds(~tmp & repmat(maskHasEdge,1,2));
    intersectionId  = obj.Intersections.Attributes{maskIsPicked,'intersection'}(maskHasEdge);
    
    % Create node table
    nodeNames       = unique(strtrim(cellstr(num2str(trackIds(:),'%u'))));
    NodeTable       = table(nodeNames,'VariableNames',{'Name'});
    
    % Create edge table
    edgeStr         = reshape(strtrim(cellstr(num2str(edge(:),'%u'))),[],2);
    edgeName        = strtrim(cellstr(num2str(intersectionId(:),'%u')));
    EdgeTable       = table(edgeStr,edgeName,'VariableNames',{'EndNodes','Name'});
    
    % Create digraph and plot it
    obj.Digraph         = digraph(EdgeTable,NodeTable);
    obj.GraphHandles    = plot(obj.AxesHandles(obj.AxesMeta.spi(2,3)),obj.Digraph);
end