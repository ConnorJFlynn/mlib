function qc_impact = anc_qc_impacts(qc, qatts)
% qc_impact =  anc_qc_impacts(qc, qatts)
% generates a value of 0,1,2 if qc is good, indeterminate, or bad 
% based on VAP convention qc flags.
% Should also handle bit-mapped mentor QC
   qc_bits = fieldnames(qatts);
   
   if (isfield(qatts,'description')...
         &&(~isempty(findstr('0 = Good',qatts.description)))...
         &&(~isempty(findstr('1 = Indeterminate',qatts.description)))...
         &&(~isempty(findstr('2 = Bad',qatts.description)))...
         &&(~isempty(findstr('3 = Missing',qatts.description)))) % plot summary qs
      qc_impact = qc;
   elseif isfield(qatts,'bit_1_description') % This is detailed QC

   
   tests = [];
   i = 0;
   % Counting backwards to find the last defined bit test
   while isempty(tests)&&(i< length(qc_bits))
      tests = sscanf(qc_bits{end-i},'bit_%d');
      i = i+1;
   end
   if ~isempty(tests)
       qc_size = size(qc);
       if sum(qc_size>1)==1
           
           qc_tests = zeros([tests,length(qc)]);
           for t = tests:-1:1
               if isfield(qatts, ['bit_',num2str(t),'_assessment'])
                   bad = findstr(upper(qatts.(['bit_',num2str(t),'_assessment'])),'BAD');
                   if bad
                       qc_tests(t,:) = 2*bitget(uint32(qc), t);
                   else
                       qc_tests(t,:) = bitget(uint32(qc), t);
                   end
                   desc{t} = ['test #',num2str(t),': ',[qatts.(['bit_',num2str(t),'_description'])]];
               end
           end
           if tests>1
               qc_impact = max(qc_tests);
           else
               qc_impact = qc_tests;
           end
       elseif sum(qc_size>0)==2
           qc_tests = zeros([tests,size(qc)]);
           for t = tests:-1:1
               if isfield(qatts, ['bit_',num2str(t),'_assessment'])
                   bad = findstr(upper(qatts.(['bit_',num2str(t),'_assessment'])),'BAD');
                   if bad
                       qc_tests(t,:,:) = 2*bitget(uint32(qc), t);
                   else
                       qc_tests(t,:,:) = bitget(uint32(qc), t);
                   end
                   desc{t} = ['test #',num2str(t),': ',[qatts.(['bit_',num2str(t),'_description'])]];
               end
           end
           if tests>1
               qc_impact = max(qc_tests);
           else
               qc_impact = qc_tests;
           end           
           
       end
   else
      qc_impact = zeros(size(qc));
   end

   else % this is "old" qc
      qc_impact = 2.*double(qc>0);
      missing(find(bitget(qc,1)))=3;
   end
   qc_impact = squeeze(qc_impact);
   return
