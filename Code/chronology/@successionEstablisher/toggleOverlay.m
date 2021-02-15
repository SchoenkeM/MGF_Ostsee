function toggleOverlay(obj)

    if obj.Overlay
        set(obj.LineHandles,...
            {'Visible'},      {'on'})
        set(obj.IntersectionHandles,...
            {'Visible'},      {'on'})
  	else
        set(obj.LineHandles,...
            {'Visible'},      {'off'})
        set(obj.IntersectionHandles,...
            {'Visible'},      {'off'})
    end
end