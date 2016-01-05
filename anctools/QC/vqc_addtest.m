function [qc,bit] = vqc_addtest(qc,qc_test);
% [qc, bit] = vqc_addtest(qc,qc_test);
% add or replace qc to an existing vap-type qc field.
% Needs to include a string describing the test
% If the assessment of the test is not supplied it is assumed to be "Bad".
% The bit number of the test is optional, if none supplied then it is added
% to end of qc field.
% The vector of test value is optional.  If none supplied, the bit value
% remains zero.
bit = [];
if ~exist('qc','var')
   disp('add_vqc error: no qc field supplied!')
   return
end
if ~exist('qc_test','var')
   disp('add_vqc error: no qc test supplied!')
   return
end
if ~isfield(qc_test,'description')
   disp('add_vqc error: no description for test supplied!')
   return   
end
if ~isfield(qc_test,'assessment')
   qc_test.assessment = 'Bad';
end
next_bit =vqc_lasttest(qc)+1;
while isfield(qc.atts,['bit_',num2str(next_bit),'_description'])
   next_bit = next_bit +1;
end
if ~isfield(qc_test,'bit')
   qc_test.bit = next_bit;
end

while next_bit < qc_test.bit
   qc.atts.(['bit_',num2str(next_bit),'_description']).data = 'test not defined';
   qc.atts.(['bit_',num2str(next_bit),'_assessment']).data = 'Bad';
   next_bit = next_bit +1;
end
   qc.atts.(['bit_',num2str(qc_test.bit),'_description']).data = qc_test.description;
   qc.atts.(['bit_',num2str(qc_test.bit),'_description']).datatype = 2;
   qc.atts.(['bit_',num2str(qc_test.bit),'_assessment']).data = qc_test.assessment;
   qc.atts.(['bit_',num2str(qc_test.bit),'_assessment']).datatype = 2;
   qc.atts = init_ids(qc.atts);
      %Now assign value

   if isfield(qc_test,'value')
      if ~isa(qc_test.value,'logical')&&(max(qc_test.value)<=length(qc.data))
         qc_test.value_ii = qc_test.value;
         qc_test.value = false(size(qc.data));
         qc_test.value(qc_test.value_ii) = true;
      end
      qc_type = class(qc.data);
      if findstr(qc_type,'int')==1
         qc_type = ['u',qc_type];
         fhandle = str2func(qc_type);
         qc.data = fhandle(qc.data);
      end
         
      qc.data = bitset(qc.data, qc_test.bit,qc_test.value);
   end
   bit = qc_test.bit;
   return
   

   