function write(obj,varargin)
% write  Write the geojsonFile content to disk
%   WRITE writes the contents of the attribute table of the geojsonFile
%   handle to a .geojson file on disk.
%
%   Syntax
%     WRITE(geojsonFile)
%     WRITE(__,filepath)
%
%   Description
%     WRITE(geojsonFile) overwrite the original .geojson file
%     WRITE(__,filepath) write to a new .geojson file at 'filepath'
%
%   Example(s)
%     WRITE(geojsonFile)
%     WRITE(geojsonFile,'./newFile.geojson')
%
%
%   Input Arguments
%     geojsonFile - geojsonFile handle
%       geojsonFile handle
%         The geojsonFile handle whose .geojson file should be written.
%
%     filepath - path to new file
%       char | cellstr
%         A valid .geojson filepath to write to. It can be provided as a
%         char or a scalar cellstr.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also GEOJSONFILE, READ
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

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
    
    % Check file permission
    if ~obj.PermissionWrite && newFile
        error('MGFOstsee:geojsonFile:write:noWritePermission',...
            'Write permission is set to false.')
    end
    
    % TODO: check if filename has a valid file extension
    
    % Convert the current attribute table to a struct thats suitable for
    % the next step
    jsonStruct     = encodeGeojsonStruct(obj);
    
    % Encode the struct to the json format with MATLAB's built in json file
    % encoder
    text = jsonencode(jsonStruct);
    
    % Write to a file on disk
    fileId = fopen(filePath,'w');
    fprintf(fileId,'%s',text);
    fclose(fileId);
end