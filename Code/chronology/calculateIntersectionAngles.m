function calculateIntersectionAngles(intersections,lines)
% calculateIntersectionAngles  Calculate angles of lines at intersection
%   CALCULATEINTERSECTIONANGLES calculates the acute angle of two lines at
%   their intersection
%
%   Syntax
%     CALCULATEINTERSECTIONANGLES(intersections,lines)
%
%   Description
%     CALCULATEINTERSECTIONANGLES(intersections,lines) calculates the
%       angles and writes them to the intersection attribute table
%
%   Example(s)
%     CALCULATEINTERSECTIONANGLES(intersections,lines)
%
%
%   Input Arguments
%     intersections - geojsonFile handle
%       geojsonFile
%         The geojsonFile handle pointing to the .geojson file that holds
%         the intersection information.
%
%     lines - geojsonFile handle
%       geojsonFile
%         The geojsonFile handle pointing to the .geojson file that holds
%         the line information.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also GEOJSONFILE
%
%   Copyright (c) 2021 David Clemens (dclemens@geomar.de)
%

    % Define function to convert any angle at an intersection of two lines
    % into the acute angle
    acuteAngle = @(a) abs(rem(90 + a,180) - 90);
    
    % Initialize
    angle = NaN(intersections.NFeatures,1);
    for ff = 1:intersections.NFeatures % Loop over all intersections
        % Get intersection vertex
        point       = intersections.Attributes{ff,'coordinates'}{:}';
        
        % Get track ids of tracks involved in the intersection
        trackAId	= intersections.Attributes{ff,'track'};
        trackBId	= intersections.Attributes{ff,'track_2'};
        
        % Get line index of these tracks
        lineAInd    = lines.Attributes{:,'track'} == trackAId;
        lineBInd    = lines.Attributes{:,'track'} == trackBId;
        
        % Get line vertices
        lineA       = squeeze(lines.Attributes{lineAInd,'coordinates'}{:});
        lineB       = squeeze(lines.Attributes{lineBInd,'coordinates'}{:});
       
        % Compute squared Euclidean distances for all line vertices to the
        % intersection point
        distA       = sum((point - lineA) .^ 2, 2);
        distB       = sum((point - lineB) .^ 2, 2);
        
        % Find the smallest squared distance and use that as an index into
        % the line vertices
        closestA    = lineA(distA == min(distA),:);
        closestB    = lineB(distB == min(distB),:);
        
        % Create normalized vectors
        vectorA     = normalizedVector(point,closestA);
        vectorB     = normalizedVector(point,closestB);
        
        % Calculate the angle. This complex version is stable for the
        % special cases of parallel or orthogonal vectors. It is even more
        % complex becaus MATLAB's 'cross' does not handle 2D vectors.
        angle(ff)   = atan2(norm(det([vectorB;vectorA])), dot(vectorA,vectorB));
    end
    % Convert all angles to acute angles and convert to integer. UInt8
    % suffices as the acute angle will be in the interval of [0 90].
    intersections.Attributes{:,'angle'} = uint8(acuteAngle(rad2deg(angle)));
    
    function v = normalizedVector(P0,P1)
        v = (P1 - P0)/norm(P1 - P0);  % Normalized vectors
    end
end