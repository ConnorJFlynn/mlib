function cvar = con_var(y)
% minimize NSR 
N = min([120,length(y)]);
N = length(y);
for n = 2:N
   y_bar = mean(y(1:n));
   y_ns = std(y(1:n));
   
   cvar.n(n-1) = n;
   cvar.cvar(n-1) = y_ns./y_bar;
end

figure; plot(cvar.n, cvar.cvar,'-o');


return