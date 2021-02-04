function showIntersection(obj)

    try
        delete(obj.LineHandles)
        delete(obj.IntersectionHandles)
    catch
        
    end
    
    intersection = obj.CurrentIntersection;
    
    lineColor   = [0.8941    0.1020    0.1098
                   0.2157    0.4941    0.7216];
	clr         = {'\color[rgb]{0.8941,0.1020,0.1098}'
                   '\color[rgb]{0.2157,0.4941,0.7216}'
                   '\color[rgb]{0,0,0}'
                   '\color[rgb]{0.8,0.8,0.8}'};
    
    spny    = obj.AxesMeta.spny;
    spi     = obj.AxesMeta.spi;
    
    lineIndices         = obj.Intersections.Attributes{obj.IntersectionOrder(intersection),{'track','track_2'}};
	intersectionData	= cat(2,obj.Intersections.Attributes.coordinates{:})';
    
    % Extract top track from intersection file and set it as selected
	topTrack   = obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'topTrack'};
    if topTrack == 0
        obj.SelectedTrack = 0;
    elseif topTrack == obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'track'}
        obj.SelectedTrack = 1;
    elseif topTrack == obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'track_2'}
        obj.SelectedTrack = 2;
    end
    
    maskLinesInd 	= find(any(obj.Lines.Attributes{:,'track'} == lineIndices,2));
    nLines          = numel(maskLinesInd);
    obj.LineHandles          = gobjects(nLines,1);
    
        
    col     = 2;
    for ln = 1:nLines
        
        lineData            = squeeze(obj.Lines.Attributes.coordinates{maskLinesInd(ln)});
        XData               = lineData(:,1);
        YData               = lineData(:,2);
        for row = 1:spny
            obj.LineHandles(spi(row,col),ln)	= plot(obj.AxesHandles(spi(row,col)),XData,YData,...
                'LineWidth',    2,...
                'Color',        lineColor(ln,:));
        end
    end

    XData   = intersectionData(obj.IntersectionOrder(intersection),1);
    YData   = intersectionData(obj.IntersectionOrder(intersection),2);

	for row = 1:spny
        obj.IntersectionHandles(spi(row,col),1) = scatter(obj.AxesHandles(spi(row,col)),XData,YData,50,...
            'Marker',           'o',...
            'MarkerFaceColor',  'w',...
            'MarkerEdgeColor',  'k');
	end

    set(obj.AxesHandles(spi(1,1)),...
        'XLim',     XData + [-1 1].*obj.BufferDistance,...
        'YLim',     YData + [-1 1].*obj.BufferDistance)
    
    highlightSelection(obj)
    
    % set 'isPicked' flag
    obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'isPicked'} = true;
end