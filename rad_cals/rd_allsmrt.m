function esr_smart = rd_allsmrt
% esr_smart = rd_allsmrt
% CJF: wrote this a little while ago (FY19?)
% Can't resist making comparisons to Odelle Coddington's ESR best-estimate
% Parses AllSMRTETR.txt file which contain a column for nm and  7 different ESR spectra we want
% plus two irregular spectra we don't want. Read it with a call to read
% only the first 8 of all rows.
fname = getfullname('AllSMRTETR.txt','AllSmrt','Select All SMART ETR file.');
fid = fopen(fname);
% nm	SMARTS_ChKur	SMARTS_Gueymard	SMARTS_newKur	SMARTS_oldKur	SMARTS_ThKur	SMARTS_Wehrli_WRC85	SMARTS_CebChKur
header = fgetl(fid);

format_str = ['%f %f %f %f %f %f %f %f %*[^\r\n]'];
C = textscan(fid, format_str);
fclose(fid);
esr_smart.nm = C{1};
esr_smart.ChKur = C{2};
esr_smart.Guey = C{3};
esr_smart.newKur = C{4};
esr_smart.oldKur = C{5};
esr_smart.ThKur = C{6};
esr_smart.Wehrli = C{7};
esr_smart.CebChKur = C{8};
%Trim off bogus values at end...
esr_smart.nm = esr_smart.nm(1:2002);
esr_smart.CebChKur = esr_smart.CebChKur(1:2002);
esr_smart.ChKur = esr_smart.ChKur(1:2002);
esr_smart.Guey = esr_smart.Guey(1:2002);
esr_smart.newKur = esr_smart.newKur(1:2002);
esr_smart.oldKur = esr_smart.oldKur(1:2002);
esr_smart.ThKur = esr_smart.ThKur(1:2002);
esr_smart.Wehrli = esr_smart.Wehrli(1:2002);

figure; plot(esr_smart.nm, [esr_smart.ChKur,esr_smart.Guey,esr_smart.newKur,esr_smart.ThKur,esr_smart.Wehrli,esr_smart.CebChKur],'-');
legend('ChKur','Guey','newKur','ThKur','Wehrli','CebChKur');xlim([200,3000]); title('Use CebChKur, also very close to new Guey')

% 
ssi = anc_load(['D:\drag and plop\radiation_cals\cal_sources_references_xsec\ESR\ssi_v02r01_monthly_s201801_e201812_c20190409.nc'])


return