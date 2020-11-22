function fnAddSimpleLegend(legendStrings, legendColorMap)
    hold on;

    h = zeros(length(legendStrings), 1);
    for i = 1:length(legendStrings)
        h(i) = plot(NaN,NaN,'Color', legendColorMap(i,:));
    end
    
%     h(1) = plot(NaN,NaN,'or');
%     h(2) = plot(NaN,NaN,'ob');
%     h(3) = plot(NaN,NaN,'ok');
%     legend(h, 'red','blue','black');
    legend(h, legendStrings);

end
