function [qc] = vqc_delete_test(qc,bit);
% [qc] = vqc_delete_test(qc,qc_test);
% delete a qc test (definition and results) from an existing vap-type qc field.
% Needs to include the qc structure and the test number to delete.

if ~exist('qc','var')
   disp('vqc_delete_test error: no qc field supplied!')
   return
end
if ~exist('bit','var')
   disp('vqc_insert_test error: no bit position supplied!')
   return
end

qc_type = class(qc.data);
if findstr(qc_type,'int')==1
   qc_type = ['u',qc_type];
   fhandle = str2func(qc_type);
   qc.data = fhandle(qc.data);
end

last_bit =vqc_lasttest(qc);
if bit<=last_bit
   for next_bit = bit:last_bit-1
   qc.atts.(['bit_',num2str(next_bit),'_description']) = qc.atts.(['bit_',num2str(next_bit+1),'_description']);
   qc.atts.(['bit_',num2str(next_bit),'_assessment']) = qc.atts.(['bit_',num2str(next_bit+1),'_assessment']);
   qc.data = bitset(qc.data,next_bit,bitget(qc.data,next_bit+1));
   end
   qc.atts = rmfield(qc.atts,['bit_',num2str(last_bit),'_description']);
   qc.atts = rmfield(qc.atts, ['bit_',num2str(last_bit),'_assessment']);
qc.data = bitset(qc.data,last_bit,0);   
end
return
