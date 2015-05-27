function [rad,taut]=radiancecldf(nwn,p,t,w,pcld,ipsfc)
if pcld==0; 
    nll=60; 
else; 
    [C,nll]=min(abs(p-pcld));
end;
if nll<ipsfc+3; 
    nll=ipsfc+3; 
end;
global pref
global tref
global wref
global oref
global prsq
global delp
global coeff
global o3
global wn
nl=60;
%[coeff]=read_taucoeff();
nwnu=nwn+333;
dryc=coeff.dry(:,:,nwnu);
wetc=coeff.wet(:,:,nwnu);
oznc=coeff.ozn(:,:,nwnu);
o=o3;
taud=taudryf(t,dryc,ipsfc);
tauw=tauwetf(t,w,wetc,ipsfc);
tauo=tauoznf(t,o,oznc,ipsfc);
taut=taud.*tauw.*tauo;
rad=hisrudccldf(wn(nwn),taut,t,nll,ipsfc);

function taud=taudryf(t,dryc,ipsfc)
global pref
global tref
global prsq
global delp
        
        nl=60;
        tl=zeros(60,1);       
        trap=-999.99;
        delt=0.;
        for j=1:nl
            taud(j)=1;
            delt=delt+abs(t(j)-tl(j));
            tl(j)=t(j);
        end
        if(delt==0.) 
            taul=1.;
        else
            sumt=0.;
            sums=0.;
            for j=ipsfc:nl
                delt=t(j)-tref(j);
                if(j>1)
                    jm1=j-1;
                    delt=0.5*(delt+t(jm1)-tref(jm1));
                end
                
                dtdp=delt*delp(j);
                sumt=sumt+dtdp;
                sums=sums+dtdp*pref(j);
                xx(1,j)=delt;
                xx(2,j)=delt*delt;
                xx(3,j)=sumt/pref(j);
                xx(4,j)=2.*sums/prsq(j);
            end
            taul=1;
        end
        taud=zeros(nl,1);
        taud(ipsfc)=1.;
        
        for j=ipsfc:nl
            if (taul==0)
                taud(j)=taul;
            else
                yy=dryc(5,j);
                if (yy==trap)
                    taul=0;
                    taud(j)=taul;
                end
                for i=1:4
                    yy=yy+dryc(i,j)*xx(i,j);
                end
                
                yy=min(yy,0);
                cc=yy;
                tauy=taul*exp(yy);
                taul=tauy;
                taud(j)=taul;
            end
        end         
function tauw=tauwetf(t,w,wetc,ipsfc)
global pref
global tref
global wref
global prsq
global delp
        tl=zeros(40,1);
        wl=zeros(40,1);
        trap=-999.99;
        nl=60;
        nw=40;
        nx=9;
        nc=nx+1;
        delt=0.;
        delw=0.;
        taul=0.;
        for j=ipsfc:nw
            tauw(j)=1;
            delt=delt+abs(t(j)-tl(j));
            tl(j)=t(j);
            delw=delw+abs(w(j)-wl(j));
            wl(j)=w(j);
        end
        if((delt+delw)==0.) 
            taul=1.;
        else
            sumw=0.;
            sums=0.;
            for j=1:nw
                delt=t(j)-tref(j);
                delw=w(j)-wref(j);
                wdep=abs(delp(j))*w(j);
                if(j>1)
                    jm1=j-1;
                    delt=0.5*(delt+t(jm1)-tref(jm1));
                    delw=0.5*(delw+w(jm1)-wref(jm1));
                    wdep=abs(delp(j))*0.5*(w(j)+w(jm1));
                end
                
                dtdp=delt*delp(j);
                sums=sums+dtdp*pref(j);
                dwdp=delw*delp(j);
                sumw=sumw+dwdp*pref(j);
                sqw(j)=sqrt(wdep);
                xx(1,j)=delt;
                xx(2,j)=2.*sums/prsq(j);
                
                xx(3,j)=delw;
                xx(4,j)=2.*sumw/prsq(j);
                xx(5,j)=delt*sqw(j);
                xx(6,j)=delt*delt*sqw(j);
                xx(7,j)=delw*sqw(j);
                xx(8,j)=delw*delw*sqw(j);
                xx(9,j)=delw*delt*sqw(j);
                
                
            end
            taul=1;
        end
        tauw=zeros(nl,1);
        tauw(ipsfc)=1.;
        
        for j=ipsfc:nw
            if (taul==0)
                tauw(j)=taul;
            else
                yy=wetc(nc,j);
                if (yy==trap)
                    taul=0;
                    tauw(j)=taul;
                end
                for i=1:nx
                    yy=yy+wetc(i,j)*xx(i,j);
                end
                
                yy=min(yy,0)*sqw(j);
                
                tauy=taul*exp(yy);
                taul=tauy;
                tauw(j)=taul;
            end
        end
        taul=tauw(nw);
        tauw(nw+1:nl)=taul;
function tauo=tauoznf(t,o,oznc,ipsfc)
global pref
global tref
global oref
global prsq
global delp
        tl=zeros(60,1);
        ol=zeros(60,1);
        trap=-999.99;
        nl=60;
        nw=40;
        nx=9;
        nc=nx+1;
        delt=0.;
        delo=0.;
        taul=0.;
        for j=1:nl
            tauo(j)=1;            
            delt=delt+abs(t(j)-tl(j));
            tl(j)=t(j);
            delo=delo+abs(o(j)-ol(j));
            ol(j)=o(j);
        end
        if((delt+delo)==0.) 
            taul=1.;
        else
            sumo=0.;
            sums=0.;
            for j=ipsfc:nl
                tauo(j)=1;
                delt=t(j)-tref(j);
                delo=o(j)-oref(j);
                odep=abs(delp(j))*o(j);
                if(j>1)
                    jm1=j-1;
                    delt=0.5*(delt+t(jm1)-tref(jm1));
                    delo=0.5*(delo+o(jm1)-oref(jm1));
                    odep=abs(delp(j))*0.5*(o(j)+o(jm1));
                end
                
                dtdp=delt*delp(j);
                sums=sums+dtdp*pref(j);
                dodp=delo*delp(j);
                sumo=sumo+dodp*pref(j);
                sqo(j)=sqrt(odep);
                xx(1,j)=delt;
                xx(2,j)=2.*sums/prsq(j);
                xx(3,j)=delo;
                xx(4,j)=2.*sumo/prsq(j);
                xx(5,j)=delt*sqo(j);
                xx(6,j)=delt*delt*sqo(j);
                xx(7,j)=delo*sqo(j);
                xx(8,j)=delo*delo*sqo(j);
                xx(9,j)=delo*delt*sqo(j);
                
                
            end
            taul=1;
        end
        tauo=zeros(nl,1);
        %tauo(1)=1.;
        
        for j=ipsfc:nl
            if (taul==0)
                tauo(j)=taul;
            else
                yy=oznc(nc,j);
                if (yy==trap)
                    taul=0;
                    tauo(j)=taul;
                end
                for i=1:nx
                    yy=yy+oznc(i,j)*xx(i,j);
                end
                
                yy=min(yy,0)*sqo(j);
                
                tauy=taul*exp(yy);
                taul=tauy;
                tauo(j)=taul;
            end
        end
function rad=hisrudccldf(wn,taut,t,nll,ipsfc)
%tau1=taut(1);
tau1=1;
tau2=0;
t1=t(1);
ILO=ipsfc;
rad=0.;
b1=wnplan(wn,t1);
b2=b1;
if ILO<nll
      for i=ILO:nll
         tau2=taut(i);
         if(tau1 < tau2)
             tau2=tau1;
         end
         t2=t(i);
         
         b2=wnplan(wn,t2);
         
         rad=rad+.5*(b1+b2)*(tau1-tau2);
         tau1=tau2;
         b1=b2;
      end
      if(nll<60); rad=rad+b2*tau2; end;
else
    rad=b1;
end;


