function tbl = decodeGeojsonStruct(s)

    nFeatures       = numel(s.features);
    emptyProperties	= false(nFeatures,1);
    emptyGeometry 	= false(nFeatures,1);
    for ff = 1:nFeatures
        emptyProperties(ff) = isempty(s.features(ff).properties);
        emptyGeometry(ff)   = isempty(s.features(ff).geometry);
    end
    
    tbl = struct2table(cat(1,s.features.properties));
    
    tmp                     = table;
    tmp(~emptyGeometry,:)   = struct2table(cat(1,s.features.geometry));
    
    tbl = cat(2,tbl,tmp);
end