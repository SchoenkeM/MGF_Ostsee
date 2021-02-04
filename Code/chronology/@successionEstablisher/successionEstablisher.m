classdef successionEstablisher < handle
    
    properties
        
        Intersections geojsonFile
        IntersectionOrder double
        Lines geojsonFile
        RasterData struct = struct('A',[],'X',[],'Y',[],'Alpha',[]);
        
        BufferDistance double = 50
        
        Digraph digraph = digraph()
    end
    properties % (Hidden)
        GraphHandles
        FigureHandles
        BackgroundAxisHandle
        TitleHandle
        AxesHandles
        AxesMeta
        RasterHandles
        LineHandles
        IntersectionHandles
    end
    properties (SetObservable)
        CurrentIntersection double = 1
        SelectedTrack double = 0
    end
    properties (Dependent)
        NAxes
        NRaster
        NIntersections
    end
    methods
        function obj = successionEstablisher(lines,intersections,varargin)
            
            import internal.stats.parseArgs
            
            % parse Name-Value pairs
            optionName          = {'BackgroundRaster','IntersectionOrder','BufferDistance'}; % valid options (Name)
            optionDefaultValue  = {struct('A',[],'X',[],'Y',[],'Alpha',[]),[],50}; % default value (Value)
            [backgroundRaster,...
             intersectionOrder,...
             bufferDistance] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
         
            
            obj.RasterData          = backgroundRaster;
            obj.Lines               = lines;
            obj.Intersections       = intersections;
            obj.BufferDistance      = bufferDistance;
            
            
            if numel(intersectionOrder) ~= obj.NIntersections
                error('MGFOstsee:successionEstablisher:invalidIntersectionOrderSize',...
                    'The intersection order has an invalid number of elements.')
            end
            obj.IntersectionOrder	= intersectionOrder;
            
            
            
            addlistener(obj,'CurrentIntersection','PostSet',@successionEstablisher.handlePropertyChangeEvents);
            addlistener(obj,'SelectedTrack','PostSet',@successionEstablisher.handlePropertyChangeEvents);
            
            initializeFigure(obj)
            initializeDigraph(obj)
        end
    end
    methods
        initializeFigure(obj)
        drawBackground(obj)
        zoomToRaster(obj)
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