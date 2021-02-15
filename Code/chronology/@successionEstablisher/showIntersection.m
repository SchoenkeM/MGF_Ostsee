function showIntersection(obj)

    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'loading intersection ...')
    drawnow
    
    hLineBack   = findobj(obj.LineHandles,'Tag','LineBack');
    hLineFront  = findobj(obj.LineHandles,'Tag','LineFront');
    
    intersection = obj.CurrentIntersection;
    
    clr     = obj.Colors;
    
    spny    = obj.AxesMeta.spny;
    spnxr   = obj.AxesMeta.spnxr;
    spi     = obj.AxesMeta.spi;
    spir    = obj.AxesMeta.spir;
    
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
    
    for ln = 1:nLines
        maskLines   = cat(1,hLineBack.UserData) == ln;
        lineData            = squeeze(obj.Lines.Attributes.coordinates{maskLinesInd(ln)});
        XData               = lineData(:,1);
        YData               = lineData(:,2);
        
        set(hLineBack(maskLines),...
            {'XData'},      {reshape(XData,1,[])},...
            {'YData'},      {reshape(YData,1,[])})
        set(hLineFront(maskLines),...
            {'XData'},      {reshape(XData,1,[])},...
            {'YData'},      {reshape(YData,1,[])})
    end
    XData   = intersectionData(obj.IntersectionOrder(intersection),1);
    YData   = intersectionData(obj.IntersectionOrder(intersection),2);
    set(obj.IntersectionHandles,...
            {'XData'},      {reshape(XData,1,[])},...
            {'YData'},      {reshape(YData,1,[])})

    set(obj.AxesHandles(spi(1,1)),...
        'XLim',     XData + [-1 1].*obj.BufferDistance,...
        'YLim',     YData + [-1 1].*obj.BufferDistance)
    
    % set 'isPicked' flag
    obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'isPicked'} = true;
    
    % Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end