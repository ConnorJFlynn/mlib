function [MT_TSI,altitude,scat_467,scat_530,scat_660,bscat_467,bscat_530,bscat_660,abs_467,abs_530,abs_660,...
          scat_467_STP,scat_530_STP,scat_660_STP,bscat_467_STP,bscat_530_STP,bscat_660_STP,abs_467_STP,abs_530_STP,abs_660_STP,...
          gamma,f_RH,T_TSI,p_TSI,RH_TSI,T_ambient,p_ambient,RH_ambient,lowRH,midRH,highRH,humid_flag,alpha_TSI,alpha_abs]=read_Neph_ambient;

%   1. Mission time (s)
%   2. altitude (m)
%   3. blue total scattering at ambient T,P,RH (Mm-1)
%   4. green total scattering at ambient T,P,RH (Mm-1)
%   5. red total scattering at ambient T,P,RH (Mm-1)
%   6. blue back scatter at ambient T,P,RH (Mm-1)
%   7. green back scatter at ambient T,P,RH (Mm-1)
%   8. red back scatter at ambient T,P,RH (Mm-1)
%   9. blue absorption at ambient T,P,RH (Mm-1)
%   10. green absorption at ambient T,P,RH (Mm-1)
%   11. red absorption at ambient T,P,RH (Mm-1)
%   12. blue total scattering at chemical STP, RH<40% (Mm-1)
%   13. green total scattering at chemical STP, RH<40% (Mm-1)
%   14. red total scattering at chemical STP, RH<40% (Mm-1)
%   15. blue back scatter at chemical STP, RH<40% (Mm-1)
%   16. green back scatter at chemical STP, RH<40% (Mm-1)
%   17. red back scatter at chemical STP, RH<40% (Mm-1)
%   18. blue absorption at chemical STP, RH<40% (Mm-1)
%   19. green absorption at chemical STP, RH<40% (Mm-1)
%   20. red absorption at chemical STP, RH<40% (Mm-1)
%   21. gamma
%   22. f(RH) (85%/40%)
%   23. Nephelometer temperature (K) [average of inlet and sample T]
%   24. Nephelometer pressure (mb)
%   25. Nephelometer RH (%)
%   26. Ambient temperature (K)
%   27. Ambient pressure (mb)
%   28. Ambient RH (%)
%   29. RH (%) in lowRH neph -- RR#3
%   30. RH (%) in midRH neph -- RR#1
%   31. RH (%) in highRH neph -- RR#2
%   32. Humidograph flag (0 is good, 0 < flag < 8 implies 1-8 mission times in the average is (are) suspect)

[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\nephs_psap\uw*.txt','Choose Neph data file');
fid=fopen([pathname filename]); 
data=fscanf(fid,'%g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[32,inf]);
fclose(fid);

MT_TSI=data(1,:);
altitude=data(2,:)/1e3; % convert  to km
scat_467=data(3,:)/1e3; % convert  to 1/km
scat_530=data(4,:)/1e3;
scat_660=data(5,:)/1e3;
bscat_467=data(6,:)/1e3; % convert  to 1/km
bscat_530=data(7,:)/1e3;
bscat_660=data(8,:)/1e3;
abs_467=data(9,:)/1e3;
abs_530=data(10,:)/1e3;
abs_660=data(11,:)/1e3;
scat_467_STP=data(12,:)/1e3; % convert  to 1/km
scat_530_STP=data(13,:)/1e3;
scat_660_STP=data(14,:)/1e3;
bscat_467_STP=data(15,:)/1e3; % convert  to 1/km
bscat_530_STP=data(16,:)/1e3;
bscat_660_STP=data(17,:)/1e3;
abs_467_STP=data(18,:)/1e3;
abs_530_STP=data(19,:)/1e3;
abs_660_STP=data(20,:)/1e3;
gamma=data(21,:);
f_RH=data(22,:);
T_TSI=data(23,:)-273.15;
p_TSI=data(24,:);
RH_TSI=data(25,:);
T_ambient=data(26,:)-273.15;
p_ambient=data(27,:);
RH_ambient=data(28,:);
lowRH=data(29,:);
midRH=data(30,:);
highRH=data(31,:);
humid_flag=data(32,:);

%compute alpha for TSI using all 3 wavelengths
for i=1:length(MT_TSI)
    x=log([0.467,0.530,0.660]);
    y=log([scat_467(i),scat_530(i),scat_660(i)]);
    [p,S] = polyfit(x,y,1);
    alpha_TSI(i)=-p(1);
end

%compute alpha for PSAP using all 3 wavelengths
for i=1:length(MT_TSI)
    x=log([0.467,0.530,0.660]);
    y=log([abs_467(i),abs_530(i),abs_660(i)]);
    if isreal(y)
        [p,S] = polyfit(x,y,1);
        a0_abs(i)=p(2); 
        alpha_abs(i)=-p(1);
    else
        a0_abs(i)=0; 
        alpha_abs(i)=1;
    end
end