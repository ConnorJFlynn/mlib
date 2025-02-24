function [cods, cods_121] = cat_tzr_cod_mats ; 


files = getfullname('tzr_cods.*.mat','tzr_cods','Select them ALL');
cods = load(files{1});

for f = 2:length(files)
   cods_ = load(files{f});
   cods.cod1.time = [cods.cod1.time; cods_.cod1.time];
   cods.cod1.cod = [cods.cod1.cod; cods_.cod1.cod];
   cods.cod2.time = [cods.cod2.time; cods_.cod2.time];
   cods.cod2.cod = [cods.cod2.cod; cods_.cod2.cod];
   cods.cod10.time = [cods.cod10.time; cods_.cod10.time];
   cods.cod10.cod = [cods.cod10.cod; cods_.cod10.cod];
   cods.cod11.time = [cods.cod11.time; cods_.cod11.time];
   cods.cod11.cod = [cods.cod11.cod; cods_.cod11.cod];
end

% figure_(1); 
% subplot(2,2,1); hist(cods.cod1.cod(cods.cod1.cod>.15&cods.cod1.cod<99),50); title('Ze1');
% subplot(2,2,2); hist(cods.cod2.cod(cods.cod2.cod>.15&cods.cod2.cod<99),50); title('Ze2');
% subplot(2,2,3); hist(cods.cod10.cod(cods.cod10.cod>.15&cods.cod10.cod<99),50); title('TWST10');
% subplot(2,2,4); hist(cods.cod11.cod(cods.cod11.cod>.15&cods.cod11.cod<99),50);  title('TWST11');

[ainb, bina]=nearest(cods.cod1.time, cods.cod2.time, 2/(24*60*60));
cods_1_2.time = cods.cod1.time(ainb); 
cods_1_2.cod1 = cods.cod1.cod(ainb); cods_1_2.cod2 = cods.cod2.cod(bina);

[cind, dinc]=nearest(cods.cod10.time, cods.cod11.time, 2/(24*60*60));
cods_10_11.time = cods.cod10.time(cind); 
cods_10_11.cod10 = cods.cod10.cod(cind); cods_10_11.cod11 = cods.cod11.cod(dinc);

[einf, fine] = nearest(cods_1_2.time, cods_10_11.time,2/(24*60*60));
cods_121.time = cods_1_2.time(einf);
cods_121.cod1 = cods_1_2.cod1(einf); cods_121.cod2 = cods_1_2.cod2(einf);
cods_121.cod10 = cods_10_11.cod10(fine); cods_121.cod11 = cods_10_11.cod11(fine);% fixed on 2024-12-20

[pname] =fileparts(files{1}); pname = [pname, filesep];
% save([pname, 'tzr_all_cods.mat'],'-struct','cods');
% save([pname, 'tzr_all_cods_1to1.mat'],'-struct','cods_121');

figure_(5); 

good1 = cods_121.cod1>.15&cods_121.cod1<99;
good1(2:end) = good1(1:end-1)&good1(2:end); good1(1:end-1) = good1(1:end-1)&good1(2:end);
good1(2:end) = good1(1:end-1)&good1(2:end); good1(1:end-1) = good1(1:end-1)&good1(2:end);
good1(2:end) = good1(1:end-1)&good1(2:end); good1(1:end-1) = good1(1:end-1)&good1(2:end);
good1(2:end) = good1(1:end-1)&good1(2:end); good1(1:end-1) = good1(1:end-1)&good1(2:end);
subplot(2,2,1); histogram(cods_121.cod1(good1),'facecolor','r'); title('SASZe1'); xlabel('Cloud OD');ylabel('Counts');

good2 = cods_121.cod2>.15&cods_121.cod2<99;
good2(2:end) = good2(1:end-1)&good2(2:end); good2(1:end-1) = good2(1:end-1)&good2(2:end);
good2(2:end) = good2(1:end-1)&good2(2:end); good2(1:end-1) = good2(1:end-1)&good2(2:end);
good2(2:end) = good2(1:end-1)&good2(2:end); good2(1:end-1) = good2(1:end-1)&good2(2:end);
good2(2:end) = good2(1:end-1)&good2(2:end); good2(1:end-1) = good2(1:end-1)&good2(2:end);
subplot(2,2,2); histogram(cods_121.cod2(good2)); title('SASZe2');  xlabel('Cloud OD'); ylabel('Counts');


good10 = cods_121.cod10>.15&cods_121.cod10<99;
good10(2:end) = good10(1:end-1)&good10(2:end); good10(1:end-1) = good10(1:end-1)&good10(2:end);
good10(2:end) = good10(1:end-1)&good10(2:end); good10(1:end-1) = good10(1:end-1)&good10(2:end);
good10(2:end) = good10(1:end-1)&good10(2:end); good10(1:end-1) = good10(1:end-1)&good10(2:end);
good10(2:end) = good10(1:end-1)&good10(2:end); good10(1:end-1) = good10(1:end-1)&good10(2:end);
subplot(2,2,3); histogram(cods_121.cod10(good10)); title('TWST10');  xlabel('Cloud OD');ylabel('Counts');

good11 = cods_121.cod11>.15&cods_121.cod11<99;
good11(2:end) = good11(1:end-1)&good11(2:end); good11(1:end-1) = good11(1:end-1)&good11(2:end);
good11(2:end) = good11(1:end-1)&good11(2:end); good11(1:end-1) = good11(1:end-1)&good11(2:end);
good11(2:end) = good11(1:end-1)&good11(2:end); good11(1:end-1) = good11(1:end-1)&good11(2:end);
good11(2:end) = good11(1:end-1)&good11(2:end); good11(1:end-1) = good11(1:end-1)&good11(2:end);
subplot(2,2,4); histogram(cods_121.cod11(good11));  title('TWST11');  xlabel('Cloud OD');ylabel('Counts');
sgtitle('Histograms of cloud OD reported for ~38K concurrent retrievals')
end