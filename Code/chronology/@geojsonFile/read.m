function read(obj)
% read  Read the geojsonFile content from disk
%   READ reads the contents of the .geojson file behind the geojsonFile
%   handle from disk.
%
%   Syntax
%     READ(geojsonFile)
%
%   Description
%     READ(geojsonFile) reads the content of the geojsonFile.
%
%   Example(s)
%     READ(geojsonFile)
%
%
%   Input Arguments
%     geojsonFile - geojsonFile handle
%       geojsonFile handle
%         The geojsonFile handle whose .geojson file should be read.
%
%
%   Name-Value Pair Arguments
%
%
%   See also GEOJSONFILE, WRITE
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    import geojsonFile.decodeGeojsonStruct
    
    % Check file permission
    if ~obj.PermissionRead
        error('MGFOstsee:geojsonFile:read:noReadPermission',...
            'Read permission is set to false.')
    end
    
    % Read .geojson file using MATLAB's built in json file decoder
    obj.Data        = jsondecode(fileread(obj.Filepath));
    
    % Convert the result to a readable attribute table
	obj.Attributes  = decodeGeojsonStruct(obj.Data);
    
    % Also store the CRS seperately
    obj.CRS         = obj.Data.crs;
end