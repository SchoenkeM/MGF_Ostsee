function highlightSelection(obj)


    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'selecting top track ...')
    drawnow
    
    intersection    = obj.CurrentIntersection;
    intersectionId  = obj.Intersections.Attributes{obj.IntersectionOrder(intersection),'intersection'};
    lineIndices     = obj.Intersections.Attributes{obj.IntersectionOrder(intersection),{'track','track_2'}};
    
	clrTex          = obj.ColorsTex;
    
	switch obj.SelectedTrack
        case 1
            txt	= {sprintf('intersection %u %s(id:%u)%s: Which track is on top/newer?',...
                        intersection,...
                        clrTex{4},intersectionId,...
                        clrTex{3});...
                   sprintf('%s%strack %u (◀)%s%s or %strack %u (▶)',...
                        '\bf',clrTex{1},lineIndices(1),'\rm',...
                        clrTex{3},...
                        clrTex{2},lineIndices(2))};
                    
            obj.Intersections.Attributes{obj.IntersectionOrder(obj.CurrentIntersection),'topTrack'} = obj.Intersections.Attributes{obj.IntersectionOrder(obj.CurrentIntersection),'track'};
        case 2
            txt	= {sprintf('intersection %u %s(id:%u)%s: Which track is on top/newer?',...
                        intersection,...
                        clrTex{4},intersectionId,...
                        clrTex{3});...
                   sprintf('%strack %u (◀)%s or %s%strack %u (▶)%s',...
                        clrTex{1},lineIndices(1),...
                        clrTex{3},...
                        '\bf',clrTex{2},lineIndices(2),'\rm')};
            obj.Intersections.Attributes{obj.IntersectionOrder(obj.CurrentIntersection),'topTrack'} = obj.Intersections.Attributes{obj.IntersectionOrder(obj.CurrentIntersection),'track_2'};
        case 0
            txt	= {sprintf('intersection %u %s(id:%u)%s: Which track is on top/newer?',...
                        intersection,...
                        clrTex{4},intersectionId,...
                        clrTex{3});...
                   sprintf('%strack %u (◀)%s or %strack %u (▶)',...
                        clrTex{1},lineIndices(1),...
                        clrTex{3},...
                        clrTex{2},lineIndices(2))};
            obj.Intersections.Attributes{obj.IntersectionOrder(obj.CurrentIntersection),'topTrack'} = 0;
    end

    % Set title text
    set(obj.TitleHandle,...
        'String',       txt,...
        'Interpreter',  'tex')
    drawnow
    
    initializeDigraph(obj)
    
    % Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end