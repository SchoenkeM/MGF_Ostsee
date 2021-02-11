function initializeLines(obj)

    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'loading intersection ...')
    drawnow
    
    clr     = obj.Colors;
    
    spny    = obj.AxesMeta.spny;
    spnxr   = obj.AxesMeta.spnxr;
    spi     = obj.AxesMeta.spi;
    spir    = obj.AxesMeta.spir;
    iir     = reshape(1:numel(spir),size(spir,2),size(spir,1))';
    
    nLines          = 2; % There are always 2 lines involved in an intersection
    obj.LineHandles         = gobjects(numel(spir),2*nLines);
    obj.IntersectionHandles	= gobjects(numel(spir),1);
    
    XData   = NaN(2,1);
    YData   = NaN(2,1);
    
    for row = 1:spny
        for col = 1:spnxr
            for ln = 1:nLines
                % Draw line background
                obj.LineHandles(iir(row,col),2*(ln - 1) + 2)	= plot(obj.AxesHandles(spi(row,col)),XData,YData,...
                    'LineWidth',    6,...
                    'Color',        'w',...
                    'Tag',          'LineBack',...
                    'UserData',     ln);
                % Draw line foreground
                obj.LineHandles(iir(row,col),2*(ln - 1) + 1)	= plot(obj.AxesHandles(spi(row,col)),XData,YData,...
                    'LineWidth',    2,...
                    'Color',        clr(ln,:),...
                    'Tag',          'LineFront',...
                    'UserData',     ln);
            end
            % Draw intersection
            obj.IntersectionHandles(iir(row,col),1) = scatter(obj.AxesHandles(spi(row,col)),XData,YData,50,...
                'Marker',           'o',...
                'MarkerFaceColor',  'w',...
                'MarkerEdgeColor',  'k');
        end
    end
    
    % Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end