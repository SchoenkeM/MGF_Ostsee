classdef geojsonFile < handle
	% geojsonFile  Interface with .geojson files
    % GEOJSONFILE allows reading and writing from and to .geojson files. 
    %
    % ClassName Properties:
    %   Filepath - Path to the file
    %   Attributes - Attribute table of the file including geometry
    %   CRS - Coordinate reference system of the file
    %   NFeatures - Number of features in the file
    %
    % ClassName Methods:
    %   geojsonFile - Constructor method
    %   read - Reads the content of the file
    %   write - Writes the attribute table to the file
    %   
    %
    % Copyright (c) 2021 David Clemens (dclemens@geomar.de)
    %

    properties
        Filepath char % Path to the file
        Attributes table % Attribute table of the file including geometry
        CRS % Coordinate reference system of the file
    end
    properties (Hidden)
        Data
        Permission char = 'r'
        FileExtension char = '.geojson'
    end
    properties (Dependent, Hidden)
        PermissionRead logical
        PermissionWrite logical
    end
    properties (Dependent) 
        NFeatures double % Number of features in the file
    end
    
    methods
        function obj = geojsonFile(path,varargin)      
        % geojsonFile  Open and read a .geojson file
        %   GEOJSONFILE opens and reads a .geojson file.
        %
        %   Syntax
        %     obj = GEOJSONFILE(path)
        %     obj = GEOJSONFILE(path,permission)
        %
        %   Description
        %     obj = GEOJSONFILE(path) opens the .geojson file at path 'path'.
        %     obj = GEOJSONFILE(path,permission) additionally set the read and/or
        %       write permissions
        %
        %   Example(s)
        %     obj = GEOJSONFILE('./stations.geojson')
        %     obj = GEOJSONFILE('./stations.geojson','rw')
        %
        %
        %   Input Arguments
        %     path - path to the file
        %       char | cellstr
        %         The full path to the .geojson file including the file extension.
        %         It can be provided as char or as a scalar cellstr.
        %
        %     permission - file permission
        %       'r' (default) | 'w' | 'rw'
        %         Sets the read/write permissions of the file. Read-only is the
        %         default.
        %
        %
        %   Output Arguments
        %     obj - GEOJSONFILE handle
        %       GEOJSONFILE
        %         A GEOJSONFILE handle.
        %
        %
        %   Name-Value Pair Arguments
        %
        %
        %   See also 
        %
        %   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
        %
            
            narginchk(1,2)
            
            pathClass = class(path);
            if ischar(path)
                path = cellstr(path);
            end
            if ~iscellstr(path)
                error('MGFOstsee:chronology:establishSuccession:invalidInputType',...
                    'The third input argument should be a ''char'' or ''cellstr''. Was ''%s'' instead.',pathClass)
            end
            
            % TODO: add file extension check
            % TODO: add check that only a scalar path is provided
            
            if nargin == 1
                permission = 'r';
            elseif nargin == 2
                permission = varargin{1};
            end
            
            obj.Filepath    = path;
            obj.Permission  = permission;
            
            obj.read;
        end
    end
    
    methods
        read(obj)
        write(obj,varargin)
    end
    
    methods (Access = private)
        s = encodeGeojsonStruct(tbl)
    end
    methods (Static, Access = private)
        tbl = decodeGeojsonStruct(s)
    end
    
    % Get methods
    methods
        function PermissionRead = get.PermissionRead(obj)
            PermissionRead = ismember('r',obj.Permission);
        end
        function PermissionWrite = get.PermissionWrite(obj)
            PermissionWrite = ismember('w',obj.Permission);
        end
        function NFeatures = get.NFeatures(obj)
            NFeatures = size(obj.Attributes,1);
        end
    end
end