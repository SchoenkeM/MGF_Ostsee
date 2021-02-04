function calculateIntersectionAngles(intersections,lines)

    acuteAngle = @(a) abs(rem(90 + a,180) - 90);
    angle = NaN(intersections.NFeatures,1);
    for ff = 1:intersections.NFeatures
        point       = intersections.Attributes{ff,'coordinates'}{:}';
        
        trackAId	= intersections.Attributes{ff,'track'};
        trackBId	= intersections.Attributes{ff,'track_2'};
        lineAInd    = lines.Attributes{:,'track'} == trackAId;
        lineBInd    = lines.Attributes{:,'track'} == trackBId;
        
        lineA       = squeeze(lines.Attributes{lineAInd,'coordinates'}{:});
        lineB       = squeeze(lines.Attributes{lineBInd,'coordinates'}{:});
       
        
        % Compute squared Euclidean distances:
        distA       = sum((point - lineA) .^ 2, 2);
        distB       = sum((point - lineB) .^ 2, 2);
        % Find the smallest squared distance and use that as an index into the line verteces:
        closestA    = lineA(distA == min(distA),:);
        closestB    = lineB(distB == min(distB),:);
        
        vectorA     = normalizedVector(point,closestA);
        vectorB     = normalizedVector(point,closestB);
        
        angle(ff)   = atan2(norm(det([vectorB;vectorA])), dot(vectorA,vectorB));
    end
    intersections.Attributes{:,'angle'} = uint8(acuteAngle(rad2deg(angle)));
    
    function v = normalizedVector(P0,P1)
        v = (P1 - P0)/norm(P1 - P0);  % Normalized vectors
    end
end