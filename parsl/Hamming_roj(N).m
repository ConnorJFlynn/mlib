 
function [W]=Hamming_roj(N)

for i=1:N
    k=i-1;
    W[i]=0.54 - 0.46*cos(2*pi*k/(N-1));
end    