classdef geojsonFile < handle
    properties
        Filepath char
        Attributes table
        CRS
    end
    properties %(Hidden)
        Data
        Permission char = 'r'
        FileExtension char = '.geojson'
    end
    properties (Dependent) %(Hidden)
        PermissionRead logical
        PermissionWrite logical
    end
    
    methods
        function obj = geojsonFile(path,varargin)
            
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
    
    methods %(Access = Private)
        s = encodeGeojsonStruct(tbl)
    end
    methods (Static) %(Access = Private)
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
    end
end