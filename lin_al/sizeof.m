function A = sizeof(a,A)
% A = sizeof(A,a)
% When provided A of size MxN and vector a with length M or length N,
% orients "a" as necessary to match the orientqation of A suitable for 
% element by element operations.  
% If A is square, there is no apriori preferred orientation.  You may need
% to manually transpose a to yield the desired orientation. 

!! Fix me!  
!! I should work with any input.  
!! Right now I may fail under some conditions.
if nargin == 2 && any(size(a)==1) && ~isempty(intersect(size(A), length(a)))

  if ~any(size(A)==size(a)) % then we need to transpose a.
      a = a';
  end
  i = find(size(A)==length(a),1,'first')
  if i == 1
      A = a*ones([1,size(A,2)]);
  else
      A = ones([size(A,1),1])*a;
  end

    
end