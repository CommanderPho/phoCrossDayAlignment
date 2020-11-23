function [fakePlotHandles, legendObj] = fnAddSimpleLegend(legendStrings, legendColorMap, onAxis)
    hold on;
    fakePlotHandles = zeros(length(legendStrings), 1);
    for i = 1:length(legendStrings)
        if exist('onAxis','var')
            fakePlotHandles(i) = plot(onAxis, NaN, NaN, 'Color', legendColorMap(i,:));
        else
            fakePlotHandles(i) = plot(NaN,NaN,'Color', legendColorMap(i,:));
        end
    end
    
    if exist('onAxis','var')
        legendObj = legend(fakePlotHandles, legendStrings);
    else
        legendObj = legend(fakePlotHandles, legendStrings);
    end
        
    

end
