function [last_bit] = vqc_lasttest(qc,qc_test);
% [bit] = vqc_lasttest(qc);
% Returns the number of the last bit test, 0 if none.
last_bit = 0;
while isfield(qc.atts,['bit_',num2str(last_bit+1),'_description'])
      last_bit = last_bit +1;
end

return
      