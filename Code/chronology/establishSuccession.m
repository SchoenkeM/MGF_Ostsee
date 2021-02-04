function establishSuccession(intersetionsPath,linesPath,rasterPaths,varargin)

            
    import internal.stats.parseArgs

    % parse Name-Value pairs
    optionName          = {'ResetIntersections'}; % valid options (Name)
    optionDefaultValue  = {false}; % default value (Value)
    [resetIntersections] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    rasterPathsClass = class(intersetionsPath);
    if ischar(rasterPaths)
        rasterPaths = cellstr(rasterPaths);
    end
    if ~ischar(intersetionsPath)
        error('MGFOstsee:chronology:establishSuccession:invalidInputType',...
            'The first input argument should be a ''char''. Was ''%s'' instead.',class(intersetionsPath))
    end
    if ~ischar(linesPath)
        error('MGFOstsee:chronology:establishSuccession:invalidInputType',...
            'The second input argument should be a ''char''. Was ''%s'' instead.',class(intersetionsPath))
    end
    if ~iscellstr(rasterPaths)
        error('MGFOstsee:chronology:establishSuccession:invalidInputType',...
            'The third input argument should be a ''char'' or ''cellstr''. Was ''%s'' instead.',rasterPathsClass)
    end
    
    intersections   = geojsonFile(intersetionsPath,'rw');
    lines           = geojsonFile(linesPath);
    
    % Remove duplicate entries if necessary (The 'Line intersections'
    % QGIS algorithm produces duplicates)
    intersectionCoordinates     = intersections.Attributes{:,'coordinates'};
    intersectionCoordinates     = cat(2,intersectionCoordinates{:})';
    [uIntersectionCoordinates,uIntersectionCoordinatesInd]    = unique(intersectionCoordinates,'rows');
    if size(uIntersectionCoordinates,1) < size(intersectionCoordinates,1)
        intersections.Attributes = intersections.Attributes(uIntersectionCoordinatesInd,:);
        intersections.write;
    end
    
    % Add intersection ids if necessary
    if resetIntersections || ~ismember('intersection',intersections.Attributes.Properties.VariableNames)
        intersections.Attributes{:,'intersection'} = (1:intersections.NFeatures)';
        intersections.write;
    end
    % calculate acute angles at intersection if necessary
    if ~ismember('angle',intersections.Attributes.Properties.VariableNames)
        calculateIntersectionAngles(intersections,lines);
        intersections.write;
    end
    % Add topTrack column if necessary
    if resetIntersections || ~ismember('topTrack',intersections.Attributes.Properties.VariableNames)
        intersections.Attributes{:,'topTrack'} = 0;
        intersections.write;
    end
    % Add isPicked column if necessary
    if resetIntersections || ~ismember('isPicked',intersections.Attributes.Properties.VariableNames)
        intersections.Attributes{:,'isPicked'} = false;
        intersections.write;
    end    
    
    nRaster     = numel(rasterPaths);
    raster      = struct('A',[],'X',[],'Y',[],'Alpha',[],'Az',[]);

    for rr = 1:nRaster
      	info = imfinfo(rasterPaths{rr});
        
        % Get hillshade azimuth
        tmp             = regexp(info.Filename,'_AZ(\d{1,3})_EL\d{1,2}_ZF\d+\.tif{1,2}$','tokens');
        raster(rr).Az   = str2double(tmp{:}{:});
        
        % Read geotif
        [raster(rr).A,raster(rr).X,raster(rr).Y,~] = geoimread(rasterPaths{rr});
        
        % Create alpha mask
        raster(rr).Alpha               	= raster(rr).A == str2double(info.GDAL_NODATA);
        raster(rr).A(raster(rr).Alpha)	= NaN;
    end
    
    % Generate data for prioritization
    sortData    = intersections.Attributes(:,{'track','track_2','angle'});
    sortData    = outerjoin(sortData,lines.Attributes,...
                    'LeftKeys',         {'track'},...
                    'RightKeys',        {'track'},...
                    'MergeKeys',        true,...
                    'RightVariables',   {'trawl'},...
                    'Type',             'left');
    sortData    = outerjoin(sortData,lines.Attributes,...
                    'LeftKeys',         {'track_2'},...
                    'RightKeys',        {'track'},...
                    'MergeKeys',        true,...
                    'RightVariables',   {'trawl'},...
                    'Type',             'left');
	sortData.Properties.VariableNames{ismember(sortData.Properties.VariableNames,'track_2_track')} = 'track_2';
	sortData.Properties.VariableNames{ismember(sortData.Properties.VariableNames,'trawl_sortData')} = 'trawl';
	sortData.Properties.VariableNames{ismember(sortData.Properties.VariableNames,'trawl_right')} = 'trawl_2';
    sortData.trawlScore     = sum(sortData{:,{'trawl','trawl_2'}} > 0,2);
    
    % This is the ordering:
    %   1. intersections where both tracks involved are part of a trawl
    %      track pair are prioritised
    %   2. intersections where the tracks meet the closest to 90° are
    %      prioritised
    [~,intersectionIndices]	= sortrows(sortData,{'trawlScore','angle'},{'descend','descend'});
    % TODO: prioritise the order of these indeces. See
    % https://github.com/davidclemens/MGF-Ostsee/issues/3.
    
    
    SE = successionEstablisher(lines,intersections,...
        'BackgroundRaster',     raster,...
        'IntersectionOrder',    intersectionIndices);
    
    keepRunning     = true;
    intersection    = 1;
    while keepRunning
        
        SE.CurrentIntersection  = intersection;
        
        waitForValidKey = true;
        while waitForValidKey
            key = waitForKeyPress;
            switch key
                case 'downarrow'
                    intersection        = max([1,intersection - 1]);
                    waitForValidKey     = false;
                case 'uparrow'
                    intersection        = min([SE.NIntersections,intersection + 1]);
                    waitForValidKey     = false;
                case 'leftarrow'
                    SE.SelectedTrack    = 1;
                    waitForValidKey     = false;
                case 'rightarrow'
                    SE.SelectedTrack    = 2;
                    waitForValidKey     = false;
                case 'space'
                    SE.SelectedTrack    = 0;
                    waitForValidKey     = false;
                case 'escape'
                    waitForValidKey     = false;
                    keepRunning         = false;
                case 's'
                    waitForValidKey     = false;
                    SE.Intersections.write;
                otherwise
                    
            end
        end
    end
end