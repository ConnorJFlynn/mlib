function [wn1,radcal]= radcalccldf(pmm,tmm,qmm,pcld,ipsfc)
%main program to calculate the radiance from normalized raob profiles
main_init;

p=pmm;t=tmm; q=qmm;

nv=5000;
dwn=0.482170;
wnmin1=359.6180;
wnmin2=1789.7305;
radcal(1:nv)=0;
for nwn=1:nv
    nwn1=nwn+333;
    if (nwn<=2656)
        wn1(nwn)=wnmin1+dwn*(nwn1-1);
    else
        wn1(nwn)=wnmin2+dwn*(nwn-2656-1+3034-3010-1);
    end
%     if ((wn1(nwn)>549 && wn1(nwn)<801) || (wn1(nwn)> 889 && wn1(nwn)<1351) || (wn1(nwn)>2039 && wn1(nwn)<2251));
        radcal(nwn)=radiancecldf(nwn,p,t,q,pcld,ipsfc);
%     end;
    
end

