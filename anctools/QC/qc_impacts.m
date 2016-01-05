function qc_impact = qc_impacts(qc)
% qc_impact = qc_impacts(qc);
% generates a value of 0,1,2 if qc is good, indeterminate, or bad 
% based on VAP convention qc flags.
   qc_bits = fieldnames(qc.atts);
   tests = [];
   i = 0;
   while isempty(tests)&&(i< length(qc_bits))
      tests = sscanf(qc_bits{end-i},'bit_%d');
      i = i+1;
   end
   if length(tests>0)
      qc_tests = zeros([tests,length(qc.data)]);
      for t = tests:-1:1
          if isfield(qc.atts, ['bit_',num2str(t),'_assessment'])
         bad = findstr(upper(qc.atts.(['bit_',num2str(t),'_assessment']).data),'BAD');
         if bad
            qc_tests(t,:) = 2*bitget(uint32(qc.data), t);
         else
            qc_tests(t,:) = bitget(uint32(qc.data), t);
         end
         desc{t} = ['test #',num2str(t),': ',[qc.atts.(['bit_',num2str(t),'_description']).data]];
          end
      end
      if tests>1
         qc_impact = max(qc_tests);
      else
         qc_impact = qc_tests;
      end
   else
      qc_impact = zeros(size(qc.data));
   end
