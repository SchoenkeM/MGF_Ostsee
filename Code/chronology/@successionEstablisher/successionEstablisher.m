classdef successionEstablisher < handle
    % successionEstablisher  Derives a chronology from intersecting lines
    % Derives a chronology from intersecting lines that were layed down on 
    % top of each other as a function of time. At each intersection the
    % user can choose via the UI which of the lines involved in the
    % intersection is on top/bottom. From this information a directed graph
    % is build and valid chronologies are derived.
    %
    % ClassName Properties:
    %   Lines - A geojsonFile handle containing the lines involved
    %   Intersections - A geojsonFile handle containing the intersections
    %     involved
    %   IntersectionOrder - The order in which the the intersections are
    %     shown in the UI
    %   BufferDistance - Distance around the intersection to show in the UI
    %   CurrentIntersection - Index of the intersection currently shown in
    %     the UI
    %   SelectedTrack - Index of the track that is chosen to be on top for 
    %     the current intersection
    %   
    %
    % ClassName Methods:
    %   successionEstablisher - Constructor method
    %
    % Copyright (c) 2021 David Clemens (dclemens@geomar.de)
    %

    properties
        Lines geojsonFile % A geojsonFile handle containing the lines involved
        Intersections geojsonFile % A geojsonFile handle containing the intersections involved
        IntersectionOrder double % The order in which the the intersections are shown in the UI
        BufferDistance double = 50 % Distance around the intersection to show in the UI        
    end
    properties (Hidden)
        GraphHandles
        FigureHandles
        BackgroundAxisHandle
        TitleHandle = gobjects()
        TextHandles = gobjects()
        AxesHandles
        AxesMeta
        RasterHandles
        RasterData struct = struct('A',[],'X',[],'Y',[],'Alpha',[],'AxesSubscripts',[]);
        LineHandles
        IntersectionHandles
        Digraph digraph = digraph()
    end
    properties (SetObservable)
        CurrentIntersection double = 0 % Index of the intersection currently shown in the UI
        SelectedTrack double = 0 % Index of the track that is chosen to be on top for the current intersection
    end
    properties (Dependent, Hidden)
        NAxes
        NRaster
        NIntersections
    end
    properties (Constant, Hidden)
        Colors = [...
            0.3020    0.6863    0.2902
            1.0000    0.4980         0
            0         0         0
            0.8       0.8       0.8]
        ColorsTex = {...
            '\color[rgb]{0.3020,0.6863,0.2902}'
            '\color[rgb]{1.0000,0.4980,0}'
            '\color[rgb]{0,0,0}'
            '\color[rgb]{0.8,0.8,0.8}'}
    end
    methods
        function obj = successionEstablisher(lines,intersections,varargin)
        % successionEstablisher  Create a successionEstablisher
        %   SUCCESSIONESTABLISHER creates a successionEstablisher and returns its
        %   handle.
        %
        %   Syntax
        %     obj = SUCCESSIONESTABLISHER(lines,intersections)
        %     obj = SUCCESSIONESTABLISHER(__,Name,Value)
        %
        %   Description
        %     obj = SUCCESSIONESTABLISHER(lines,intersections) creates a 
        %       SUCCESSIONESTABLISHER for the lines 'lines' intersecting at
        %       'intersections'.
        %     obj = SUCCESSIONESTABLISHER(__,Name,Value) specifies additional
        %       properties using one or more Name,Value pair arguments. 
        %
        %   Example(s)
        %     obj = SUCCESSIONESTABLISHER(lines,intersections)
        %     obj = SUCCESSIONESTABLISHER(lines,intersections,'IntersectionOrder',Order)
        %
        %
        %   Input Arguments
        %     lines - geojsonFile handle
        %       geojsonFile
        %         The geojsonFile handle pointing to the .geojson file that holds
        %         the line information.
        %
        %     intersections - geojsonFile handle
        %       geojsonFile
        %         The geojsonFile handle pointing to the .geojson file that holds
        %         the intersection information.
        %
        %
        %   Output Arguments
        %     obj - SUCCESSIONESTABLISHER handle
        %       SUCCESSIONESTABLISHER
        %         A SUCCESSIONESTABLISHER handle.
        %
        %
        %   Name-Value Pair Arguments
        %     BackgroundRaster - Backround raster data
        %       struct('A',[],'X',[],'Y',[],'Alpha',[],'AxesSubscripts',[]) (default) | struct
        %         A struct holding background raster data. The following fields are
        %         required: 'A' (cell values), 'X' (x-coordinate),
        %         'Y' (y-coordinate), 'Alpha' (transparency channel) and 
        %         'AxesSubscripts' (nx2 row-col indices). 'A' and
        %         'Alpha' fields hold arrays of the same size. 'X' and 'Y' are
        %         vectors with lengths corresponding to the raster dimension sizes.
        %         'AxesSubscripts' holds a list of row-col subscript pairs,
        %         indicating, on which axis/axes to show the respective raster.
        %         Multiple rasters can be supplied as a non-scalar struct.
        %
        %     IntersectionOrder - UI intersection order
        %       [] (default) numeric vector
        %         The order in which the the intersections are shown in the UI. Has
        %         to have the same size as features in 'Intersections' and hold
        %         sensible indices into the features of 'Intersections'.
        %
        %     BufferDistance - Distance around the intersection to show in the UI
        %       50 (default) 
        %         Distance around the intersection to show in the UI. The value is
        %         interpreted in the unit of the CRS.
        %
        %
        %   See also 
        %
        %   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
        %
            
            import internal.stats.parseArgs
            
            % Parse Name-Value pairs
            optionName          = {'BackgroundRaster','IntersectionOrder','BufferDistance'}; % valid options (Name)
            optionDefaultValue  = {struct('A',[],'X',[],'Y',[],'Alpha',[],'AxesSubscripts',[]),[],50}; % default value (Value)
            [backgroundRaster,...
             intersectionOrder,...
             bufferDistance] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
         
            % Assign property values
            obj.RasterData          = backgroundRaster;
            obj.Lines               = lines;
            obj.Intersections       = intersections;
            obj.BufferDistance      = bufferDistance;
            
            if numel(intersectionOrder) ~= obj.NIntersections
                error('MGFOstsee:successionEstablisher:invalidIntersectionOrderSize',...
                    'The intersection order has an invalid number of elements.')
            end
            obj.IntersectionOrder	= intersectionOrder;

            % Add property listeners
            addlistener(obj,'CurrentIntersection','PostSet',@successionEstablisher.handlePropertyChangeEvents);
            addlistener(obj,'SelectedTrack','PostSet',@successionEstablisher.handlePropertyChangeEvents);
            
            % Initialize the UI
            initializeFigure(obj)
            initializeDigraph(obj)
        end
    end
    methods
        saveIntersections(obj)
    end
    methods (Access = private)
        initializeFigure(obj)
        drawBackground(obj)
        zoomToRaster(obj)
        initializeLines(obj)
        showIntersection(obj)
        delete(obj)
        highlightSelection(obj)
        initializeDigraph(obj)
        addToDigraph(obj,intersection)
    end
    
    % Get methods
    methods
        function NAxes = get.NAxes(obj)
            NAxes = numel(obj.AxesHandles);
        end
        function NRaster = get.NRaster(obj)
            NRaster = numel(obj.RasterData);
        end
        function NIntersections = get.NIntersections(obj)
            if isempty(obj.Intersections)
                NIntersections = 0;
            else
                NIntersections = obj.Intersections.NFeatures;
            end
        end
    end
    
    % Event handler methods
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'CurrentIntersection'
                    showIntersection(evnt.AffectedObject)
                case 'SelectedTrack'
                    highlightSelection(evnt.AffectedObject)
            end
        end
    end
end