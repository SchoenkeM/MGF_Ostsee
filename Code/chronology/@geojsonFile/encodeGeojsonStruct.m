function s = encodeGeojsonStruct(obj)

    geometryVariableNames   = {'type','coordinates'};
    propertiesVariableNames = setdiff(obj.Attributes.Properties.VariableNames,geometryVariableNames);
    properties              = table2struct(obj.Attributes(:,propertiesVariableNames))';
    geometry                = table2struct(obj.Attributes(:,geometryVariableNames))';
    
    properties              = arrayfun(@(x) {x},properties);
    geometry                = arrayfun(@(x) {x},geometry);
    
    s           = obj.Data;
    % resize features in case some were added or deleted
    s.features  = repmat(obj.Data.features(1),numel(properties),1);
    [s.features(:).properties]	= properties{:};
    [s.features(:).geometry]    = geometry{:};
end