% function bit_img = bitimg(qc,N)
% Intended mainly to display bit values of a single-dimensioned bit-packed field. 
function bit_img = bitimg(qc,N)

if ~exist('qc','var')
   error('input field is requried.')
end
if ~isinteger(qc)
   if ischar(qc)
      qc = uint8(qc);
   elseif islogical(qc)
      qc = uint8(qc);
   elseif isa(qc,'single')
      qc = uint32(qc);   
   elseif isa(qc,'double')
      qc = uint64(qc);
   else
      error('qc must an integer type.')
   end
end
   s = class(qc);
   si = findstr(s,'int')+3;
   int_len = sscanf(s(si:end),'%d');
   if isempty(int_len)
      int_len = 8;
      N =0;
   end
   if exist('N','var')
      N = min(N,int_len);
   else
      N = int_len;
   end
   uhandle = str2func(['uint',num2str(int_len)]);
qc = uhandle(qc);
% check to see that qc if single-dimensioned
if ~any(size(qc)==1)
   error('qc must be single-dimensioned')
end
if size(qc,1)~=1 && size(qc,2)==1
   qc = qc';
end
% re-orient qc as row vector if necessary

if exist('N','var')&&(N>0)&&(N==floor(N))
   bit_img = repmat(false,N,length(qc));
end
for b = N:-1:1
   bit_img(b,:) = bitget(qc,b);
end
return
% status = 0;
% bw =      [0     0     0;      1     1     1];
