function epsq = sigeps(A,f,tau,nwl,nrad,iflag1);
%King's function sigeps
%Computes sigma epsilon squared of input data and the agreement of
%computed and measured tau after the inversion is completed

if iflag1==0
   %for i = 1:nwl
      %tauc = A(i,:)*f;
   %end
   tauc=A*f;
   epsq = sum((tauc-tau).^2);
elseif iflag1==1
   epsq = sum(f.^2);
end