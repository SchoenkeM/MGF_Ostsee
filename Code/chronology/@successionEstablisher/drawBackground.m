function drawBackground(obj)

    [~,~,uAzInd] = unique(cat(1,obj.RasterData.Az));
    
    spnx    = obj.AxesMeta.spnx;
    spny    = obj.AxesMeta.spny;
    spi     = obj.AxesMeta.spi;
    
    % Plot raster on all axes
    for row = 1:spny
        az = row;
        for col = 1:2
            rasterInd   = find(uAzInd == az);
            nRaster     = numel(rasterInd);
            for rr = 1:nRaster
                imagesc(obj.AxesHandles(spi(row,col)),obj.RasterData(rasterInd(rr)).X,obj.RasterData(rasterInd(rr)).Y,obj.RasterData(rasterInd(rr)).A,...
                  'AlphaData',      ~obj.RasterData(rasterInd(rr)).Alpha,...
                  'CDataMapping',   'scaled');
            end
            colormap(obj.AxesHandles(spi(row,col)),'gray')
        end
    end
end