function write(obj,varargin)
    

    narginchk(1,2)
    
    if nargin == 1
        filePath    = obj.Filepath;
        newFile     = false;
    elseif nargin == 2
        filePath    = varargin{1};
        newFile     = true;
    end

    pathClass = class(filePath);
    if iscellstr(filePath) && numel(filePath) == 1
        filePath = filePath{1};
    end
    if ~char(filePath)
        error('MGFOstsee:geojsonFile:write:invalidInputType',...
            'The second input argument should be a ''char'' or ''cellstr''. Was ''%s'' instead.',pathClass)
    end
            
    if ~obj.PermissionWrite && newFile
        error('MGFOstsee:geojsonFile:write:noWritePermission',...
            'Write permission is set to false.')
    end
    
    
    jsonStruct     = encodeGeojsonStruct(obj);
    
    text = jsonencode(jsonStruct);
    
    fileId = fopen(filePath,'w');
    fprintf(fileId,'%s',text);
    fclose(fileId);
end