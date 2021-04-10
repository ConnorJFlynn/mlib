function K = fit_it_2(Y,V)
% usual syntax: K = fit_it_2(Y, V);
% % Y must be MxN column vectors.  Array V is MxP with P-columns of length Mx1.  
% Modified 2019-12-28 to allow for non-X dependent V
% K will be NxP
base_e = V;
size(Y);
size(base_e);
K = Y'/V'; 

return
