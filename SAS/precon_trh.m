function [T_C,rh] = precon_trh(V_T,V_rh,Vcc);
% [T_C,rh] = precon_trh(V_T,V_rh,Vcc)
% ratiometric RH and T sensor
% Want to make this spiffier and only compute the individual values for
% points where the Vcc is a bit wider from the norm, else use the means
%%
rh = 100.*V_rh./Vcc;
T_n = V_T./Vcc;
[P_T,S_T,mu_T] = polyfit([0,1],[-30,100],1);
T_C = polyval(P_T,T_n,[],mu_T);
%%
% figure; plot([1:length(Vcc)],[rh,T_C],'o');
% legend('rh','T_C')
%%
return