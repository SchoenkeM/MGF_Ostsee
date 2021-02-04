function zoomToRaster(obj)
    
    XData       = cat(2,obj.RasterData.X);
    YData       = cat(2,obj.RasterData.Y);
    XLimits     = [min(XData),max(XData)];
    YLimits     = [min(YData),max(YData)];
    
    set(obj.AxesHandles(1),...
        'XLim',     XLimits,...
        'YLim',     YLimits)
end