function King_CLI(iread_sigext,flag_kingstop1,flag_save,filesave,refrac_idx,lambda,...
   taup_meas,unc_taup_meas,r_min,r_max,n_coarse_rad_bin,Q1est,mode,nitermax);

%King constrained linear inversion program
%King, Byrne, Herman, and Reagan (1978,J.A.S., 35, 2153-2167)

global nigamsv ggamsv Q1sv Q2sv Qsv fsv dnlgrsv uncdnlgrsv dnrsv uncdnrsv taucsv
global relerr dndlgrsav radcalc r3mom r2mom reff colvolume colsfcarea
global taunumint tausum nustar rg_coarse rg_fine sigext rad_bound_fine

if flag_kingstop1==1
   load kingstop1
   
elseif flag_kingstop1==0
   
[dum nwl]=size(lambda);
gaminc=2;

n_fine_rad_bin=136; %number of fine radii bins

wt=diag(1./unc_taup_meas.^2);

%Calculate second differences smoothing matrix HM of order n_coarse_rad_bin
HM = constrmtx(2,n_coarse_rad_bin);

%Calculate coarse bin boundaries and midpoints
dlogr=(log10(r_max)-log10(r_min))/(n_coarse_rad_bin);
xlogr=log10(r_min):dlogr:log10(r_max);
rad_coarse=10.^xlogr;
rg_coarse=(10.^(xlogr(1:n_coarse_rad_bin)+dlogr/2))';

M=n_fine_rad_bin/(r_max-r_min);
B=1-r_min*M;
Z=n_fine_rad_bin/n_coarse_rad_bin;
nradp1=n_coarse_rad_bin+1;
nradm1=n_coarse_rad_bin-1;
ii=1:1:nradp1;
idxfine=1:1:n_fine_rad_bin;

NK=round(0.5*(1+ (ii-1)*Z + M*rad_coarse + B));

LL=NK(1:n_coarse_rad_bin);
LH=NK(2:nradp1)-1;
NL=LH-LL;
dlgr=dlogr./(NL+1);

for i = 1:n_coarse_rad_bin,
      idxL=LL(i):1:LH(i);
      rad_bound_fine(LL(i):LH(i))=rad_coarse(i)*10.^(dlgr(i).*(idxL-LL(i)));
end
rad_bound_fine(137)=r_max;

%Calculate fine bin (geometric) midpoints
for i = 1:n_fine_rad_bin,
   rg_fine(i)=sqrt(rad_bound_fine(i)*rad_bound_fine(i+1));
end

if iread_sigext==0 | iread_sigext==1   
	%Calculate extinction efficiency factors at fine bin midpoints
	x=mie_par(rg_fine,lambda);
	for irad=1:n_fine_rad_bin;
    for ilambda=1:length(lambda)
        N=mie_test(x(irad,ilambda));
          if N==NaN
             N=40;
          end
        N=N+10;
        [Q_ext(irad,ilambda),dummy]=mie(x(irad,ilambda),refrac_idx,N);
     end
	end

	%Calculate extinction cross sections at fine bin midpoints
	ar=pi.*rg_fine.^2.*1.E-08;
   %ar=ar';
   sigext=ones(136,nwl);
   for j=1:nwl,
   	sigext(:,j)=ar'.*Q_ext(:,j);
	end
	sigext=sigext';
   
   if iread_sigext==1
      if r_min>=0.01 & r_min<0.1
         char_min = num2str(r_min);
      	r_min_str = char_min(3:4);   
      elseif r_min>=0.1
         r_min_str = num2str(100*r_min);
      end
      
      if r_max>=1 & r_max<10
         r_max_str = num2str(10*r_max);
      elseif r_max >=10
            r_max_str = num2str(r_max);
      end
      file_effic = strcat('c:\beat\king\CLI',r_min_str,r_max_str,num2str(nwl),'w',num2str(n_coarse_rad_bin),'b.bin');
      fid=fopen(file_effic,'wb');
      fwrite(fid,sigext,'real*4')
      fclose(fid)
   end
   
elseif iread_sigext==2
	   if r_min>=0.01 & r_min<0.1
         char_min = num2str(r_min);
      	r_min_str = char_min(3:4);   
      elseif r_min>=0.1
         r_min_str = num2str(100*r_min);
      end
      
      if r_max>=1 & r_max<10
         r_max_str = num2str(10*r_max);
      elseif r_max >=10
            r_max_str = num2str(r_max);
      end
      file_effic = strcat('d:\beat\king\CLI',r_min_str,r_max_str,num2str(nwl),'w',num2str(n_coarse_rad_bin),'b.bin');
		fid=fopen(file_effic,'rb');
		sigext=fread(fid,[nwl 136],'real*4');
end

%Calculate Angstrom coefficient and corresponding nustar value
x=log(lambda);
y=log(taup_meas)';
[p,S]=polyfit(x,y,1);
nustar(2)=-p(1)+2;
nustar(1)=nustar(2)-0.5;
nustar(3)=nustar(2)+0.5;

end  %flag_kingstop loop   
   
%Calculate power law size distribution weighting function (King eqn.(8)) in fine bins
for ns=1:3,
  qold = rad_bound_fine(1).^(-nustar(ns))./nustar(ns);
   for irad = 2:n_fine_rad_bin+1,
      qnew = rad_bound_fine(irad).^(-nustar(ns))./nustar(ns);
      wnu(ns,irad-1) = qold - qnew;
      qold = qnew;
   end
end   
 
%define symbols and colors
symbol_color=['k-';'b-';'g-';'r-';'c:';'b:';'g:';'r:'];
 
%Begin loop over nustar---------------------------
for ns = 1:3,
   
w=wnu(ns,:);
   
%zero/initialize relevant quantities
igamsv=0; node=0; icount=0; niter=0; iter=0; iwl=0;
loopiter=1;

%Calculate initial power law size distribution at center of coarse bins 
dnr=rg_coarse.^(-(nustar(ns)+1));
dnlgr=log(10).*rg_coarse.*dnr;

%Begin loop over iterations---------------------------------
while loopiter==1
   
loopAmatrix=1;
   
%begin loop over A,ATA calculations+++++++++++++++++++++++++
while loopAmatrix==1
   
   %plot weighting functions w
   figure(19)
   orient landscape;
	subplot(1,3,ns)
   loglog(rg_fine,w,symbol_color(iter+1))
   hold on
   axis([.01 10. 1e-02 1e+09]);
   
   
   
   
%====================begin A,BCW,ATA==========================================   
%Calculate weighted A matrix
A=zeros(nwl,n_coarse_rad_bin);
for i = 1:nwl,
   for k = 1:n_coarse_rad_bin,
         A(i,k) = A(i,k) + sum(w(LL(k):LH(k)).*sigext(i,LL(k):LH(k)));
   end
end

%Calculate sum of size dist weights in each coarse bin
BCW(1:n_coarse_rad_bin)=0;
for i=1:n_coarse_rad_bin,
   BCW(i) = BCW(i) + sum(w(LL(i):LH(i)));
end

%Calculate weighted A'g matrix
ATG = A'*wt*taup_meas; 

%Calculate weighted A'A matrix
ATA = A'*wt*A;	
%====================end A,BCW,ATA==========================================   

gam=0; itest=0;
nnode=iter+1;	%iter replaces King's node
loopdndr=1;
exitgamloop=0;

%begin loop over gamma///////////////////////////////////////////////
while gam<=4.5*ATA(1,1)
   
%+++++++++++++++++++++++ begin matrix inversion section +++++++++++++++++++++++   
%Calculate matrix AN=(weighted A'A + gamma*smoothing matrix)
AN = ATA + gam*HM;

%invert AN matrix and solve for size distribution f vector 
ANinv = inv(AN);	%will use this later to get errors
f = ANinv*ATG;

%Calculate retrieved optical depths
taup_calc = A*f;

%Calculate performance functions Q,Q1,Q2
Q1=0; Q2=0;
for j = 2:nradm1,
   Q2 = Q2 + (f(j-1)-2*f(j)+f(j+1))^2;
end
Q1 = sum(wt*(taup_meas-taup_calc).^2);
Q = Q1 + gam*Q2;
ggam = gam/ATA(1,1);
%+++++++++++++++++++++++ end matrix inversion section +++++++++++++++++++++++   


%...............Save values for plotting or output.................
if gam>0 & ggam<=4.5
   igamsv = igamsv + 1;
   nigamsv(nnode,ns) = igamsv;
   ggamsv(igamsv,nnode,ns) = ggam;
   Q1sv(igamsv,nnode,ns) = Q1;
   Q2sv(igamsv,nnode,ns) = Q2;
   Qsv(igamsv,nnode,ns) = Q;
   fsv(:,igamsv,nnode,ns) = f;
end
%..................................................................

%begin loopdndr loop'''''''''''''''''''''''''''''''''''''''''''''''''''''''
while loopdndr==1   
   
 testiterloop=0;
   
 if gam==0
   gam=1.e-03*ATA(1,1);
   break %terminates loopdndr loop
 else
   %test f values;
   	for i=1:n_coarse_rad_bin,
			if f(i)<0 
      		gam = gaminc*gam;	%increment gam
            loopdndr = 0;
            break	%want to terminate loopdndr loop, but this just terminates for loop
      	end  
   	end   
      
      if loopdndr==1
   		itest = itest + 1;
      
      	if (itest==1) | (itest>=2 & Q1<=Q1est)
         	gamp=gam;
      	end
            
      	if itest > 0
         	gam = gaminc*gam;
         	break	%terminates loopdndr loop
      	end
      
      	sigmaf = sqrt(diag(ANinv));	%presently yields incorrect values.  Why?
			if mode==0
         	if nwl>n_coarse_rad_bin
            	s = sqrt(Q1/(nwl-n_coarse_rad_bin));
            	sigmaf = s*sigmaf;
         	end
      	end
      
      	iter = iter + 1;   
			cn = sum(BCW.*f');
      	dnlgr = dnlgr.*f;	%      	dnlgr = dnlgr.*f';
      	dnr = dnr.*f;			 %     	dnr = dnr.*f';
      	if mode~=0 | n_coarse_rad_bin<nwl
         	erdnlg = dnlgr.*(sigmaf./f);
         	erdnr = dnr.*(sigmaf./f);
         	sumerr = sum(sigmaf./f);
         	pererr = 100*sigmaf./f;
      	end
      	epsq = sigeps(A,f,taup_meas,nwl,n_coarse_rad_bin,0);	
      	ggam = gam/ATA(1,1);
      	icount = 0;
         igamsv = 0;  
      	sumerr = 100*sumerr/n_coarse_rad_bin;
         
%...............Save values for plotting or output.................
	dnlgrsv(:,ns,iter) = dnlgr';
   uncdnlgrsv(:,ns,iter) = erdnlg';
   dnrsv(:,ns,iter) = dnr';
   uncdnrsv(:,ns,iter) = erdnr';
   taucsv(:,ns,iter) = taup_calc;
  	relerr(ns,iter) = sumerr;
%..................................................................

			testiterloop=1;
         break	%exits loopdndr loop
      end  %end if loopdndr==1 branch
   end  %if gam==0...else branch
end	%end loopdndr while loop

loopdndr = 1;

if gam>4.5*ATA(1,1)
   if itest >= 1
      gam=gamp;
      itest=-10;
   elseif itest < 1
      nneg = sum(f<0);
         if nneg>(n_coarse_rad_bin-2)
            exitgamloop=1;
            loopAmatrix=0;
            loopiter=0;
         else
            [f]=adjust(f,n_coarse_rad_bin);
            icount = icount + 1
            if icount>3
               exitgamloop=1;
               loopAmatrix=0; 
               loopiter=0;
            else
               dnlgr=dnlgr.*f;
               dnr=dnr.*f;
               igamsv=0;
               testiterloop=1;
            end
         end
   end  %if itest>=1 branch
end  %if gam>4.5*ATA(1,1) branch

while testiterloop==1
 testiterloop=0;  
 if iter==nitermax
    exitgamloop=1;  %this will terminate while gamma<4.5*ATA(1,1) loop
    loopAmatrix=0;  %this will terminate while loopAmatrix==1 loop
    loopiter=0;     %this will terminate while loopiter==1
    break	%terminates while testiterloop==1 loop
 else   
    %====================begin code to alter weighting of sub-intervals for successive iterations
    LF = fix(LL + NL./2);
    LP = LF + 1;
    for i = 1:n_coarse_rad_bin
       
       if i==1
          dif1=f(i)-f(i+1);
          dif2=dif1;
          xno=f(i)+dif1;
          if(xno + f(i))<0
             xno = -f(i);
             dif1 = xno - f(i);
          end
       else		%if i>1
          xno=f(i-1);
          dif1=xno-f(i);
          if i~=n_coarse_rad_bin
             dif2=f(i)-f(i+1);   
          elseif i==n_coarse_rad_bin
             dif2=dif1;
             xn1=f(i)-dif2;
             if (xn1+f(i))<0
                dif2 = 2*f(i);
             end
          end
    	 end
        
       for L = LL(i):LF(i)
          fac = xno - dif1*(NL(i) + 2*(L-LL(i)) + 2)/(2*(NL(i) + 1));
          w(L) = w(L)*fac;
       end
       
       for L = LP(i):LH(i)
          fac = f(i) - dif2*(2*(L-LL(i))-NL(i))/(2*(NL(i) + 1));
          w(L) = w(L)*fac;
       end
       
    end	%loop over coarse bins================================sub-interval weighting adjustment
     
    exitgamloop=1;	%this will subsequently exit gamma while loop
    break	%terminate testiterloop loop  
 end  % if iter==nitermax branch
end  %while testiterloop==1 loop
 if exitgamloop==1
   exitgamlooop=0;
   break
 end
end	%end while gam<=4.5*ATA(1,1) loop

end	%end loop over A,ATA calculation:  while loopAmatrix==1

end	%end while loopiter==1 (iteration) loop

 %Calculate 2nd, 3rd moments, eff rad, vol, sfc area, opt depth by numerical
 %integration over the 136 radii intervals
 for iter=1:nitermax,
   %extrapolate dndr to r_min,r_max
   slope = log10(dnrsv(2,ns,iter)/dnrsv(1,ns,iter))/log10(rg_coarse(2)/rg_coarse(1));
   dndrcalc(1) = dnrsv(1,ns,iter)*10.^(slope*log10(r_min/rg_coarse(1)));
   slope = log10(dnrsv(n_coarse_rad_bin,ns,iter)/dnrsv(n_coarse_rad_bin-1,ns,iter))/log10(rg_coarse(n_coarse_rad_bin)/rg_coarse(n_coarse_rad_bin-1));
   dndrcalc(n_coarse_rad_bin+2) = dnrsv(n_coarse_rad_bin,ns,iter)*10.^(slope*log10(r_max/rg_coarse(n_coarse_rad_bin)));
   dndrcalc(2:n_coarse_rad_bin+1) = dnrsv(1:n_coarse_rad_bin,ns,iter);
   radcalc(1) = r_min;
   radcalc(n_coarse_rad_bin+2) = r_max;
   radcalc(2:n_coarse_rad_bin+1) = rg_coarse(1:n_coarse_rad_bin);
   
   radlog10 = log10(radcalc);
   dndrlog10 = log10(dndrcalc);
   dndr = 10.^interp1(radlog10,dndrlog10,log10(rg_fine));
   rgcubed = rg_fine.^3;
   rgsquared = rg_fine.^2;
   r3mom(iter,ns) = trapz(rg_fine,rgcubed.*dndr);
   r2mom(iter,ns) =trapz(rg_fine,rgsquared.*dndr);
   reff(iter,ns) = r3mom(iter,ns)/r2mom(iter,ns); 
   %reff(iter,ns) = r3mom(iter)/r2mom(iter); %that was wrong, fixed by John and Beat in the year of the lord 1998 on the 3rd day of November
   colvolume(iter,ns) = 4*pi*r3mom(iter)/3;
   colsfcarea(iter,ns) = 4*pi*r2mom(iter);
   
	for kwl = 1:nwl,
      integrand(kwl,:) = sigext(kwl,:).*dndr;
      taunumint(kwl,iter,ns) = trapz(rg_fine,integrand(kwl,:));
   end
   
   for j=1:136,
      dre(j) = rad_bound_fine(j+1) - rad_bound_fine(j);
   end
   
   for kwl = 1:nwl,
      extxsect = sigext(kwl,:);
      tausum(kwl,iter,ns) = sum(extxsect.*dndr.*dre);
   end   
 end  %end loop for calculating moments,etc.

end	%end nustar loop: for ns = 1:3,    ----------------------------------------------

fprintf('finished constrained linear inversion calculations\n');

if strcmp(flag_save,'true')
   save filesave
   fprintf('Workspace saved to file %s\n',filesave);
end
   