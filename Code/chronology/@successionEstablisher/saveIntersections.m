function saveIntersections(obj)

    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'saving intersections ...')
    drawnow
    
    try
        obj.Intersections.write;
    catch ME
        warning('chronology:successionEstablisher:saveIntersections',...
            'Unable to save intersections. The following error occured:\n\n\t%s\n',strjoin(cat(1,{ME.identifier},{ME.message}),'\n\t'))
    end
    
    % Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end