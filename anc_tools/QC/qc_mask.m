function [bad,indet] = qc_mask(qc);
qc_bits = fieldnames(qc.atts);
tests = [];
i = 0;
bad = zeros(['u',class(qc.data)]);
indet = bad;
   while isempty(tests)&&(i< length(qc_bits))
      tests = sscanf(qc_bits{end-i},'bit_%d');
      i = i+1;
   end

if length(tests>0)
%     bit_depth = max([8,(floor(tests/8)+1)*8]);
% %%
%     switch class(qc.data)
%         case 
%             bad = uint8(0);
%             indet = bad;
%         case 16
%             bad = uint16(0);
%         case 32 
%             bad = uint32(0);
%         otherwise
%             bad = uint64(0);
%     end
%     indet = bad;
    
%%
     for t = tests:-1:1
         bad = bitset(bad,t,~isempty(findstr(upper(qc.atts.(['bit_',num2str(t),'_assessment']).data),'BAD')));
         indet = bitset(indet,t,isempty(findstr(upper(qc.atts.(['bit_',num2str(t),'_assessment']).data),'BAD')));
     end
%%
end