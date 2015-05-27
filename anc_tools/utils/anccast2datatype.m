function val = anccast2datatype(val);
% val = anc_datacast(val);
% idea is to cast the element val.data to match val.datatype
datatype_to_class = {'uint8','char','int16','int32','single','double'};
if ~strcmp(datatype_to_class{val.datatype},class(val.data))
   switch val.datatype
      case 1
         val.data = uint8(val.data);
      case 2
         val.data = char(val.data);
      case 3
         val.data = int16(val.data);
      case 4
         val.data = int32(val.data);
      case 5
         val.data = single(val.data);
      case 6
         val.data = double(val.data);
   end
end