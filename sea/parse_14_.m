function tag = parse_14(tag, data, tb_str)
%Loran = parse_14(Loran,data,tb_str);

samples = double(tag.samples(1));
sizes = size(data);
if samples>1
   if length(sizes)>2
      for s = samples:-1:1
         % This is not working properly
         tag.(tb_str).untype_data{s} = data(:,s);
      end

   else
      for s = samples:-1:1
         tag.(tb_str).untype_data(s) = data(:,s);
      end
   end
else
   tag.(tb_str).untype_data = data';
end


