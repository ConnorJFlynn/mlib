function clr_sky = rd_clong_clr(in_file)

if ~exist('in_file','var')||~exist(in_file,'file')
    in_file = getfullname_('*.asc;*.dat','clr_times','Select clear sky file');
end

% Zdate  Ztim     Ldate  Ltim  Gclr  Sclr       dra       drb       swa       swb      CosZ      SWdn     CSWdn     DifSW    CDifSW      DifR     CDifR     NDifR
% 20070101  1526  20070101   926   350   350    0.0649   -0.6787    1268.5    1.1786    0.2712     290.0     272.7      59.8      42.9    0.2062    0.1573    0.0850
fid = fopen(in_file,'r');
header = fgetl(fid);
C = textscan(fid,['%d %d %d %d %d %d ',repmat('%f ',1,12)]);
fclose(fid);
A = C{1}; B = C{2};
[yr] = floor(A./10000); rest = mod(A, 10000);
V(:,1) = yr(:);
V(:,2) = floor(rest./100);
V(:,3) = mod(rest , 100);
V(:,4) = floor(B./100);
MM = mod(B, 100); MM = floor(MM);
V(:,5) = MM; V(:,6) = 0;
clr_sky.time = datenum(double(V));
A = C{3}; B = C{4};
[yr] = floor(A./10000); rest = mod(A, 10000);
V(:,1) = yr(:);
V(:,2) = floor(rest./100);
V(:,3) = mod(rest , 100);
V(:,4) = floor(B./100);
MM = mod(B, 100); MM = floor(MM);
V(:,5) = MM; V(:,6) = 0;
clr_sky.local = datenum(double(V));

clr_sky.Gclr  = C{5};
clr_sky.Sclr= C{6};
clr_sky.dra= C{7};
clr_sky.drb= C{8};
clr_sky.swa= C{9};
clr_sky.swb= C{10};
clr_sky.CosZ= C{11};
clr_sky.SWdn= C{12};
clr_sky.CSWdn= C{13};
clr_sky.DifSW= C{14};
clr_sky.CDifSW = C{15};
clr_sky.DifR= C{16};
clr_sky.CDifR= C{17};
clr_sky.NDifR= C{18};
clr_sky.V_UT = datevec(clr_sky.time);
clr_sky.V_loc = datevec(clr_sky.local);
% [pname, fname, ext] = fileparts(in_file);
% save([pname, filesep,fname, '.mat'],'-struct','clr_sky');
return



