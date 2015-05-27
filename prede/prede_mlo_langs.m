% read in prede sun...
in_dir = 'C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\Langley_Anal\Prede_sun_files\';
 prede = read_prede;
 prede.LatN = 19.5365;
 prede.LonE = -155.5761;
 [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
    sunae(prede.LatN, prede.LonE, prede.time);
 amm = sort(prede.airmass); amm([1 end])
 good = prede.airmass>1.15 & prede.airmass<15;
%%
% tic
%These test points determined by looking at lowest error in Vo vs Lambda
% test_ii = [338, 392,278,741,812,833,1020 ];
% 315, 400, 500, 675, 870, 940, 1020
[Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),prede.filter_5(good),2.5,5);
[Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),prede.filter_7(good),3.5,5);
[Vo,tau,Vo_, tau_, good(good)] = dbl_lang(prede.airmass(good),prede.filter_2(good),3.5,5);
%%
clear Vo tau Vo_ tau_
for f = [7:-1:1]
%    disp(['wavelength = ',num2str(Lambda(L))])
   [Vo(f), tau(f), P,S,Mu,dVo(f)] = lang(prede.airmass(good),prede.(['filter_',num2str(f)])(good));
   [Vo_(f),tau_(f), P_] = lang_uw(prede.airmass(good),prede.(['filter_',num2str(f)])(good));
   disp(['Done with ',num2str(prede.header.wl(f))])
   figure(1003);
   subplot(2,1,1);
   semilogy(prede.airmass(good), prede.(['filter_',num2str(f)])(good),'g.', prede.airmass(good),exp(polyval(P,prede.airmass(good),S,Mu)),'r');
   title(['Langley at ',num2str(prede.header.wl(f)), ' Vo=',sprintf('%0.3g',Vo(f)), ' dVo=',sprintf('%0.3g',dVo(f)),' tau=',sprintf('%0.2g',tau(f)), ' sum(good)=',sprintf('%g',sum(good))]);
   % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
   subplot(2,1,2);
   semilogy(1./prede.airmass(good), exp(real(log(prede.(['filter_',num2str(f)])(good)))./prede.airmass(good)),'g.');
   title(['Langley at ',num2str(prede.header.wl(f)),' Vo=',num2str(Vo_(f)),' tau=',num2str(tau_(f)), ' sum(good)=',num2str(sum(good))]);
   %    title(['goods=',num2str(goods),' mad=',num2str(mad),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
   hold('on');
   plot( 1./prede.airmass(good), exp(polyval(P_, 1./prede.airmass(good))),'r');
   hold('off');
end
% disp('Done!')
Langley.wl = prede.header.wl;
Langley.Vo = Vo'; 
Langley.tau = tau'; 
Langley.Vo_ = Vo_'; 
Langley.tau_ = tau_';
amm = sort(prede.airmass(good)); 
good_times = prede.time(good);
Langley.time_UTC = good_times([1 end]);
Langley.airmass = amm([1 end])
figure(1); plot(prede.header.wl, 100*[abs(Langley.Vo - Langley.Vo_)./Langley.Vo], '-')
figure(2); plot(prede.header.wl, [Langley.Vo,Langley.Vo_], '-');
[pth,fname,ext] = fileparts(prede.header.fname);
save([in_dir,'/Vo_1/', fname,'.Vo.mat'],'Langley')
