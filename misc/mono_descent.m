function [x,y] = mono_descent(x,y)


while ~mono(y) && length(y)>1
    jj = length(y);ii = jj;
while ~mono(y) && ii>0
    ii = jj-1; 
    while ii>0 && y(ii)<mean(y(ii+1:jj))
        ii = ii -1;
    end
    x(ii+1) = mean(x(ii+1:jj)); x(ii+2:jj) = [];
    y(ii+1) = mean(y(ii+1:jj)); y(ii+2:jj) = [];
    jj = ii;
end
end
return 

   
function yes = mono(x)

yes =  all(diff(x)<=0);
return


