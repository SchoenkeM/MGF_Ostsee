clear

rootFolder          = '/Users/David/Dropbox/David/university/PostDoc/ressoruces/GIS/MGF Ostsee/';
intersetionsPath    = [rootFolder,'GIS/layers/vector/TrawlMarkIntersections.geojson'];
linesPath           = [rootFolder,'GIS/layers/vector/TrawlMarks.geojson'];
rasterPath          = [rootFolder,'GIS/layers/raster/*_*_*_bathymetry_AZ*_EL*_ZF*.tif']; % Filename pattern
rasterPaths         = dir(rasterPath);
rasterPaths         = fullfile({rasterPaths.folder},{rasterPaths.name})';



establishSuccession(intersetionsPath,linesPath,rasterPaths,...
    'ResetIntersections',       true)