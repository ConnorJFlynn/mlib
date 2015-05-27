function aats = cut_aats(aats,keep);
fields = fieldnames(aats);
times = size(aats.time,2);
for f = 1:length(fields)
    field = char(fields(f));
    if size(aats.(field),2)==times && size(aats.(field),1)==1
        aats.(field) = [aats.(field)(keep)];
    end
    if size(aats.(field),2)==times && size(aats.(field),1)>1
        aats.(field) = [aats.(field)(:,keep)];
    end
    
end

return