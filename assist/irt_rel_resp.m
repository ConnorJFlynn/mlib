function IRT = irt_rel_resp; 
%This data from table 11 in IRT Handbood PDF

r2 = 'c:\case_studies\assist\docs\r2';
if exist(r2,'file');
tmp = load(r2);
IRT.rel_resp = tmp(:,2);
IRT.wn = tmp(:,1);
IRT.um = wn2um(IRT.wn); 
else
IRT_resp = [9.40 0.000000
9.46 4.580252
9.58 12.273370
9.70 29.645053
9.82 48.180234
9.94 56.015325
10.06 59.592843
10.18 59.582579
10.30 61.141282
10.42 63.120466
10.54 64.794606
10.66 66.224009
10.78 67.286336
10.90 66.575086
11.02 65.575695
11.14 65.601176
11.26 66.965032
11.38 67.696559
11.50 42.629668
11.62 14.432280
11.74 4.815956
11.80 0.000000];
IRT.um = IRT_resp(:,1);
IRT.wn = um2wn(IRT.um);
IRT.rel_resp = IRT_resp(:,2)./100;
end
% I assume these values are in percent, but dividing by 100 and integrating
% over the area yields 1.1813
% So I re-compute relative responsivity by dividing by the area under the
% curve. 
% I do this for both wavelength in um and wavenumber in 1/cm to yield
% area-normalized curves in both units.
%%
%%

% IRT.um = IRT_resp(:,1);
% IRT.wn = um2wn(IRT.um);
% IRT.rel_resp = IRT_resp(:,2)./100;
IRT.rel_resp_um = IRT.rel_resp./trapz(IRT.um, IRT.rel_resp);
IRT.rel_resp_wn = IRT.rel_resp./trapz(flipud(IRT.wn), IRT.rel_resp);
IRT.rel_resp_um = IRT.rel_resp;
IRT.rel_resp_wn = IRT.rel_resp;
IRT.cwl = trapz(flipud(IRT.um), IRT.um.*IRT.rel_resp_um)./trapz(flipud(IRT.um), IRT.rel_resp_um);
IRT.cwn = trapz(flipud(IRT.wn), flipud(IRT.wn).*IRT.rel_resp_wn)./trapz(flipud(IRT.wn), IRT.rel_resp_wn);

%%
um_txt = ([IRT.um,IRT.rel_resp_um]');
irt_um = [sprintf('%2.3f %2.3e \n',um_txt)];
wn_txt = fliplr([IRT.wn,IRT.rel_resp_wn]');
irt_wn = [sprintf('%2.3f %2.3e \n',wn_txt)];

% %%
% figure; subplot(2,1,1);
% 
% plot(IRT.um, IRT.rel_resp_um,'o-', [IRT.cwl, IRT.cwl], [0,1.1.*max(IRT.rel_resp_um)],'r:')
% title('Normalized responsivity of IRT detector')
% tx1 = text(IRT.cwl,1.1.*max(IRT.rel_resp_um),sprintf('Center wavelength = %2.3f um',IRT.cwl));
% set(tx1,'horiz','center','vert','bottom');
% xlabel('um');
% ylabel('1/um');
% 
% subplot(2,1,2);
% plot(IRT.wn, IRT.rel_resp_wn,'o-', [IRT.cwn, IRT.cwn], [0,1.1.*max(IRT.rel_resp_wn)],'r:')
% tx2 = text(IRT.cwn,1.1.*max(IRT.rel_resp_wn),sprintf('Center wavenumber = %2.3f 1/cm',IRT.cwn));
% set(tx2,'horiz','center','vert','bottom');
% xlabel('1/cm');
% ylabel('1/1/cm'); 
return