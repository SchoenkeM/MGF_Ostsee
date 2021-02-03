function read(obj)

    import geojsonFile.decodeGeojsonStruct
    
    if ~obj.PermissionRead
        error('MGFOstsee:geojsonFile:read:noReadPermission',...
            'Read permission is set to false.')
    end
    obj.Data        = jsondecode(fileread(obj.Filepath));
	obj.Attributes  = decodeGeojsonStruct(obj.Data);
    obj.CRS         = obj.Data.crs;
end