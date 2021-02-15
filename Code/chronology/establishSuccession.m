function establishSuccession(intersetionsPath,linesPath,rasterPaths,varargin)
% establishSuccession  Create and control a successionEstablisher UI
%   ESTABLISHSUCCESSION creates and controls a successionEstablisher UI
%   letting the user decide which of the two lines involved in an
%   intersection is on top.
%
%   Syntax
%     ESTABLISHSUCCESSION(intersetionsPath,linesPath,rasterPaths)
%     ESTABLISHSUCCESSION(__,Name,Value)
%
%   Description
%     ESTABLISHSUCCESSION(intersetionsPath,linesPath,rasterPaths) start a
%       sucessionEstablisher UI
%     ESTABLISHSUCCESSION(__,Name,Value) specifies additional properties
%       using one or more Name,Value pair arguments. 
%
%   Example(s)
%     ESTABLISHSUCCESSION(intersetionsPath,linesPath,rasterPaths)
%     ESTABLISHSUCCESSION(intersetionsPath,linesPath,rasterPaths,'ResetIntersections',true)
%
%
%   Input Arguments
%     intersetionsPath - Path to an intersections .geojson file
%       char
%         Path to an intersections .geojson file.
%
%     linesPath - Path to a lines .geojson file
%       char
%         Path to a lines .geojson file.
%
%     rasterPaths - Path(s) to raster .tif file(s)
%       char | cellstr
%         Path(s) to raster .tif file(s) that will be shown in the
%         background.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%     ResetIntersections - Intersections attribute table reset flag
%       false (default) | true
%         Decide if the intersection attribute table should be reset to its
%         original form (topTrack, etc. columns are then removed).
%
%
%   See also SUCCESSIONESTABLISHER, GEOJSONFILE
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%
            
    import internal.stats.parseArgs

    % Input handling and checking
    rasterPathsClass = class(intersetionsPath);
    if ischar(rasterPaths)
        rasterPaths = cellstr(rasterPaths);
    end
    nRaster                     = numel(rasterPaths);
    defaultRasterAxesSubscripts	= (1:nRaster)';
    
    % Parse Name-Value pairs
    optionName          = {'ResetIntersections','RasterAxesSubscripts'}; % valid options (Name)
    optionDefaultValue  = {false,defaultRasterAxesSubscripts}; % default value (Value)
    [resetIntersections,...
     rasterAxesSubscripts] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
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
    
    % Create geojsonFile handles
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
    % Calculate acute angles at intersection if necessary
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
    
    % Initialize
    raster      = struct('A',[],'X',[],'Y',[],'Alpha',[]);
    for rr = 1:nRaster % Loop over all raster files
        % Get image information
      	info    = imfinfo(rasterPaths{rr});
        
        % Read geotif
        [raster(rr).A,raster(rr).X,raster(rr).Y,~] = geoimread(rasterPaths{rr});
        
        % Create alpha mask
        try
            raster(rr).Alpha               	= raster(rr).A == str2double(info.GDAL_NODATA);
        catch ME
            switch ME.identifier
                case 'MATLAB:nonExistentField'
                    if ~isempty(regexp(ME.message,'''GDAL_NODATA''\.$','once'))
                        raster(rr).Alpha = false(size(raster(rr).A));
                    else
                        rethrow(ME)
                    end
                otherwise
                    rethrow(ME)
            end
        end
        raster(rr).A(raster(rr).Alpha)	= NaN; 
        
        % Asign AxesSubscripts
        raster(rr).AxesSubscripts       = rasterAxesSubscripts(rr);
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
    
    % Create intersection order
    % This is the ordering:
    %   1. intersections where both tracks involved are part of a trawl
    %      track pair are prioritised
    %   2. intersections where the tracks meet the closest to 90° are
    %      prioritised
    [~,intersectionIndices]	= sortrows(sortData,{'trawlScore','angle'},{'descend','descend'});
    % TODO: prioritise the order of these indeces. See
    % https://github.com/davidclemens/MGF-Ostsee/issues/3.    
    
    % Create successionEstablisher handle
    SE = successionEstablisher(lines,intersections,...
        'BackgroundRaster',     raster,...
        'IntersectionOrder',    intersectionIndices);
    
    % Start the user interaction with the UI
    keepRunning     = true;
    intersection    = 1; % Intersection index
    while keepRunning
        % Set current intersection
        if intersection ~= SE.CurrentIntersection
            SE.CurrentIntersection  = intersection;
        end
        
        % Loop until a valid key is pressed
        waitForValidKey = true;
        while waitForValidKey
            key = waitForKeyPress;
            switch key
                case 'downarrow'
                    % Show previous intersection
                    intersection        = max([1,intersection - 1]);
                    waitForValidKey     = false;
                case 'uparrow'
                    % Show next intersection
                    intersection        = min([SE.NIntersections,intersection + 1]);
                    waitForValidKey     = false;
                case 'leftarrow'
                    % Mark track with track index 1 as on top
                    SE.SelectedTrack    = 1;
                    waitForValidKey     = false;
                case 'rightarrow'
                    % Mark track with track index 2 as on top
                    SE.SelectedTrack    = 2;
                    waitForValidKey     = false;
                case 'space'
                    % Mark no track as on top
                    SE.SelectedTrack    = 0;
                    waitForValidKey     = false;
                case 'escape'
                    % Stop the UI
                    waitForValidKey     = false;
                    keepRunning         = false;
                case 's'
                    % Save the changes to disk
                    waitForValidKey     = false;
                    SE.saveIntersections;
                case 'o'
                    % Toggle line overlay
                    waitForValidKey     = false;
                    if SE.Overlay
                        SE.Overlay = false;
                    else
                        SE.Overlay = true;
                    end
                otherwise
                    % Continue waiting for a valid key press
            end
        end
    end
end