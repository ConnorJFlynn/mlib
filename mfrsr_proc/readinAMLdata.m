function mfr = readinAMLdata

indir = 'D:\case_studies\AML\AMLdata\aot_236\';
outdir = [indir, '..\figures\'];
if ~exist(outdir,'dir')
    mkdir(outdir)
end

%file = '20140330.txt';
filelist = dir([indir, '*txt']);

numfiles = length(filelist);

for ff=numfiles:-1:1
disp(ff)
% RUn on each file:
file = filelist(ff).name;
fname = [indir, file];

[outdata, mfr1] = importAOTfile(fname);
bads = (isNaN(mfr1.angstrom)|isNaN(mfr1.aod_415)|isNaN(mfr1.aod_500)|...
    isNaN(mfr1.aod_615)|isNaN(mfr1.aod_673)|isNaN(mfr1.aod_870)|...
    isNaN(mfr1.aod_940));

mfr1.time(bads) = []; mfr1.pwv(bads) = []; 
mfr1.aod_415(bads) = []; mfr1.aod_500(bads) = []; 
mfr1.aod_615(bads) = []; mfr1.aod_673(bads) = []; 
mfr1.aod_870(bads) = []; mfr1.aod_940(bads) = []; 
mfr1.angstrom(bads) = [];
outdata(bads,:) = [];

[aero] = aod_screen(mfr1.time, mfr1.aod_500,0.0001, 2); 
mfr1.time(~aero) = []; mfr1.pwv(~aero) = []; 
mfr1.aod_415(~aero) = []; mfr1.aod_500(~aero) = []; 
mfr1.aod_615(~aero) = []; mfr1.aod_673(~aero) = []; 
mfr1.aod_870(~aero) = []; mfr1.aod_940(~aero) = []; 
mfr1.angstrom(~aero) = [];

if ~exist('mfr','var')
    mfr = mfr1;
else
    mfr = cat_timeseries(mfr, mfr1);
end

daylabel = file(1:8);
plotlabel = ['AOD for ',daylabel];
outdata(~aero,:) = [];
% if ~isempty(outdata)
% figure1 = createdailyAOTplot(outdata(:,1), outdata(:,4:9),plotlabel);
% 
% outname = [outdir, daylabel, 'daily.png'];
% 
% saveas(figure1, outname, 'png');
% 
% close(figure1)

% end


end
figure(99); 
s(1) =subplot(2,1,1); plot(mfr.time, [mfr.aod_415,mfr.aod_500,mfr.aod_615,...
    mfr.aod_673,mfr.aod_870],'.'); legend('415','500','615','673','870');

set(s(1),'xtick',[])
ylabel('AOD')
s(2) =subplot(2,1,2); plot(mfr.time, [mfr.angstrom],'.'); legend('angstrom');
dynamicDateTicks;
ylabel('angstrom')
linkaxes(s,'x');

save([outdir, '..',filesep,'AML_MFRSR_236_AOD.mat'],'-struct','mfr')
return
