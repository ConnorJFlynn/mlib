function MatInt = hex2nm(hexmat);
%function MatInt = hex2nm(hexmat)
%usage B = MatInt(A)
%A is matrix of dimension [row,col]
%B is generated of dimension [row,1]
%B(i) = hex2dec(A(i,:))
[row,col] = size(hexmat);
B = zeros(row,1);
for i = 1:row;
B(i) = hex2dec(hexmat(i,:)); 
end;
MatInt = B;
