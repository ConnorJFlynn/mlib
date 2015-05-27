function aats = cat_aats_in(aats,aats_2);
fields = fieldnames(aats);
times = size(aats_2.time,2);
for f = 1:length(fields)
     field = char(fields(f));
    if size(aats_2.(field),2)==times
        aats.(field) = [aats.(field), aats_2.(field)];
    end
end

return