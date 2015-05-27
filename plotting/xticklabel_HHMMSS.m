function xticklabel_HHMMSS(hProp,eventData)    %#ok - hProp is unused
   hAxes = eventData.AffectedObject;
   tickValues = get(hAxes,'XTick');
   HH = floor(tickValues);
   MM = 60.*rem(tickValues,1);
   SS = floor(60.*rem(MM,1));
   MM = floor(MM);
%    SS = rem(tickValues,100); MM = floor(tickValues/100);
%    HH = floor(MM/100); MM = rem(MM,100);
   tmp = textscan(sprintf('%02.0f:%02.0f:%02.0f ',[HH;MM;SS]), '%s');
   newLabels = tmp{:};
%    for nl = 1:length(tickValues)
%    newLabels(nl) = {sprintf('%02.0f:%02.0f:%02.0f ',[HH(nl);MM(nl);SS(nl)])};
%    end
%    newLabels = arrayfun(@(value)(sprintf('%06.0f ',value)), tickValues, 'UniformOutput',false);
   set(hAxes, 'XTickLabel', newLabels);
end  % myCallbackFunction
