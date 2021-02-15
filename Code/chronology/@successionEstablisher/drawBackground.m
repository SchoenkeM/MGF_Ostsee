function drawBackground(obj)
    
    % Set status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       'rendering raster ...')
    drawnow

    spnx    = obj.AxesMeta.spnx;
    spnxr   = obj.AxesMeta.spnxr;
    spny    = obj.AxesMeta.spny;
    spi     = obj.AxesMeta.spi;
    spir    = obj.AxesMeta.spir;
    iir     = reshape(1:numel(spir),size(spir,2),size(spir,1))';
    
    % Plot raster on all axes
    for row = 1:spny
        for col = 1:spnxr
            rasterInd   = find(cat(1,obj.RasterData.AxesSubscripts) == iir(row,col));
            nRaster     = numel(rasterInd);
            if nRaster == 0
                set(obj.AxesHandles(spi(row,col)),...
                    'Visible',      'off')
                continue
            end
            for rr = 1:nRaster
                switch size(obj.RasterData(rasterInd(rr)).A,3)
                    case 4 % Alpha channel - rendered image
                        image(obj.AxesHandles(spi(row,col)),...
                            'XData',            obj.RasterData(rasterInd(rr)).X,...
                            'YData',            obj.RasterData(rasterInd(rr)).Y,...
                            'CData',            obj.RasterData(rasterInd(rr)).A(:,:,1:3),...
                            'AlphaData',        obj.RasterData(rasterInd(rr)).A(:,:,4),...
                            'AlphaDataMapping', 'scaled',...
                            'CDataMapping',     'direct');
                    case 1 % No alpha channel - float values
                        imagesc(obj.AxesHandles(spi(row,col)),obj.RasterData(rasterInd(rr)).X,obj.RasterData(rasterInd(rr)).Y,obj.RasterData(rasterInd(rr)).A,...
                            'AlphaData',        ~obj.RasterData(rasterInd(rr)).Alpha,...
                            'CDataMapping',     'scaled',...
                            'AlphaDataMapping', 'none');
                        colormap(obj.AxesHandles(spi(row,col)),'gray')
                end
            end
            drawnow
        end
    end
    
    % Clear status text
    set(findobj(obj.TextHandles,'Tag','status'),...
        'String',       '')
    drawnow
end