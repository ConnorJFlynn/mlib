%%
form_2p = ['bsp(RH%)/Bsp(~40%) = a*[1-(RH%/100)]^(-b)']
form_3p = 'bsp(RH%)/Bsp(~40%) = a*[1+b(RH%/100)]^(-c)';

% 2 parameter fit: bsp(RH%)/bsp(~40%)=a*[1-(RH%/100)]^-b
% 3 parameter fit: bsp(RH%)/bsp(~40%)=a[1+b(RH%/100)^c] 

fitsrh = ancload;
%%
aos = ancload;

%%
a2 = fitsrh.vars.fRH_Bs_R_10um_2p.data(1,:);
b2 = fitsrh.vars.fRH_Bs_R_10um_2p.data(2,:);
coh = a2.^(1./b2);
rh_ref_2p = (1-coh).*100;
test_2p_2 = a2>0;
test_2p_3a = (a2<=1)&(b2>=0);
test_2p_3b = (a2>=1)&(b2<=0);
test_2p_3 = test_2p_3a | test_2p_3b;


a3 = fitsrh.vars.fRH_Bs_R_10um_3p.data(1,:);
b3 =fitsrh.vars.fRH_Bs_R_10um_3p.data(2,:);
c3 =fitsrh.vars.fRH_Bs_R_10um_3p.data(3,:);
rh_ref_3p = 100.*real(((1-a3)./(a3.*b3)).^(1./c3));

test_3p_2 = ((1-a3)./(a3.*b3))>=0;
test_3p_3a = (((1-a3)./(a3.*b3))<=1)&(c3>=0);
test_3p_3b = (((1-a3)./(a3.*b3))>=1)&(c3<=0);
test_3p_3 = test_3p_3a | test_3p_3b;
rh = 0.01.*[30:2:90]';
lhs = ones(size(rh));
rhs = ones(size(a2));
%%

fitrh_2pp = lhs*a2 .*((1-(rh*rhs)).^(-1*lhs*b2));  
fitrh_3pp = lhs*a3 .*(1 + (lhs*b3).*((rh*rhs).^(lhs*c3)));

%
% redfity_3p[ii] = l_red3p_1um_pts[0,npts] * 
% (1. + l_red3p_1um_pts[1,npts] * (rh[ii]*0.01)^l_red3p_1um_pts[2,npts])


%%
done = false;
h = 1;
   figure;
while ~(done)
   
   %screen aos values
   goodin = serial2Hh(aos.time)>= (h-1) &serial2Hh(aos.time)< (h-1) 
 plot(rh, fitrh_2pp(:,h),'b-',rh, fitrh_3pp(:,h),'r-');
 title(['RH fits for hour ',num2str(h)])
 legend(['2P: a = ',num2str(a2(h)),' b = ',num2str(b2(h))], ...
    ['3P: a = ',num2str(a3(h)),' b = ',num2str(b3(h)),' b = ',num2str(c3(h))]);
   kk = menu('Select option','Next','Previous','Done');
   if kk == 1
      h = h + 1;
   end
   if kk == 2
      h = h -1;
   end
   if kk ==3 
      done = true;
   end
   if h > length(b2)
      h = 1;
   elseif h < 1
      h = length(b2)
   end
end
   
% a =
% b =
% aa =
% bb =
% cc =

% fit_rh = 