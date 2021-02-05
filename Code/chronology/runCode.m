% runCode
%
% This script starts a trawl mark intersection characterization session.

clear

% Decide if the intersection attribute table should be reset to its
% original form (topTrack, etc. columns are then removed).
ResetFlag   = true;

% Define filepaths
rootFolder          = '/Users/David/Dropbox/David/university/PostDoc/ressoruces/GIS/MGF Ostsee/';
intersetionsPath    = [rootFolder,'GIS/layers/vector/TrawlMarkIntersections.geojson'];
linesPath           = [rootFolder,'GIS/layers/vector/TrawlMarks.geojson'];
rasterPath        	= [rootFolder,'GIS/layers/raster/*_*_*_bathymetry_*.tif']; % Filename pattern
rasterPaths       	= dir(rasterPath);
rasterPaths         = fullfile({rasterPaths.folder},{rasterPaths.name})';
rasterPaths         = rasterPaths(~cellfun(@isempty,regexp(rasterPaths,'rendered\.tif$')));

rasterAxesSubscripts    = {[1 1;1 2];[2 1;2 2];[3 1;3 2];[1 1;1 2];[2 1;2 2];[3 1;3 2]};

% Create establishSuccession handle
establishSuccession(intersetionsPath,linesPath,rasterPaths,...
    'ResetIntersections',       ResetFlag,...
    'RasterAxesSubscripts',     rasterAxesSubscripts)