function model_neph_from_aps(aosneph, aps_dN);
if ~exist('aosneph','var')
aosneph = ancload(getfullname_('D:\case_studies\aos\naos\pvcaosnephdryM1.c1\pvcaosnephdryM1.c1.*'));
end
if ~exist('aps_dN','var')
aps_dN = load(['D:\case_studies\aos\maos-pekour-aps\tcap2013\tcap_2013_size_ver_1.mat']);
end
[ainb, bina] = nearest(aosneph.time, aps_dN.time);
aps_dN.time = aps_dN.time(bina)';
aps_dN.total_conc = aps_dN.total_conc(bina)';
aps_dN.D = aps_dN.D';
aps_dN.sdist = aps_dN.sdist';
aps_dN.sdist = aps_dN.sdist(:,bina);
aps_dN.vdist = (pi./6).*aps_dN.sdist.*(((aps_dN.D./100).^3)*ones(size(aps_dN.time)));

        aps_dN.Bs_B_1um(length(aps_dN.time)) = NaN;
        aps_dN.Bs_G_1um(length(aps_dN.time)) = NaN;
        aps_dN.Bs_R_1um(length(aps_dN.time)) = NaN;
        aps_dN.Bs_B_10um(length(aps_dN.time)) = NaN;
        aps_dN.Bs_G_10um(length(aps_dN.time)) = NaN;
        aps_dN.Bs_R_10um(length(aps_dN.time)) = NaN;

aosneph = ancsift(aosneph,aosneph.dims.time, ainb);


%%
good_1 = aosneph.vars.size_cut.data > .5 & aosneph.vars.size_cut.data < 5 & ...
    aosneph.vars.Bs_B_Dry_Neph3W_1.data > 0 & aosneph.vars.Bs_B_Dry_Neph3W_1.data < 1000;
good_10 = aosneph.vars.size_cut.data > 5 & aosneph.vars.size_cut.data < 15 & ...
    aosneph.vars.Bs_B_Dry_Neph3W_1.data > 0 & aosneph.vars.Bs_B_Dry_Neph3W_1.data < 1000;

figure(1); plot(serial2doys(aosneph.time(good_1)), aosneph.vars.Bs_B_Dry_Neph3W_1.data(good_1),'b.',...
    serial2doys(aosneph.time(good_1)),aosneph.vars.Bs_G_Dry_Neph3W_1.data(good_1),'g.',...
    serial2doys(aosneph.time(good_1)),aosneph.vars.Bs_R_Dry_Neph3W_1.data(good_1), 'r.',...
    serial2doys(aosneph.time(good_10)), aosneph.vars.Bs_B_Dry_Neph3W_1.data(good_10),'bo',...
    serial2doys(aosneph.time(good_10)),aosneph.vars.Bs_G_Dry_Neph3W_1.data(good_10),'go',...
    serial2doys(aosneph.time(good_10)),aosneph.vars.Bs_R_Dry_Neph3W_1.data(good_10), 'ro');
xlabel('day of year');
ylabel('1/Mm')
zoom('on');
%% 
mn = 0;
while mn<2
    figure(1);
mn = menu('Zoom to select region, click OK when done.','OK','Quit');

xl = xlim;

ij = find(serial2doys(aps_dN.time)>=xl(1)&serial2doys(aps_dN.time)<=xl(2));



for ii = length(ij):-1:1
    if aosneph.vars.size_cut.data(ij(ii))>.5&aosneph.vars.size_cut.data(ij(ii))<5
        disp('1 um cut')
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 450,'cut',1000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_B_1um(ij(ii)) = tmp.scattering;
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 550,'cut',1000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_G_1um(ij(ii)) = tmp.scattering;
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 700,'cut',1000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_R_1um(ij(ii)) = tmp.scattering;
    else
        aps_dN.Bs_B_1um(ij(ii)) = NaN;
        aps_dN.Bs_G_1um(ij(ii)) = NaN;
        aps_dN.Bs_R_1um(ij(ii)) = NaN;
    end
    if aosneph.vars.size_cut.data(ij(ii))>5&aosneph.vars.size_cut.data(ij(ii))<15
        disp('10 um cut')
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 450,'cut',5000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_B_10um(ij(ii)) = tmp.scattering;
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 550,'cut',5000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_G_10um(ij(ii)) = tmp.scattering;
        tmp = SizeDist_Optics(1.55+0.001i, aps_dN.D(2:end-1).*1000, aps_dN.sdist(2:end-1,ij(ii)), 700,'cut',5000, 'nephscats',true,'normalized',false,'nobackscat',false);
        aps_dN.Bs_R_10um(ij(ii)) = tmp.scattering;
    else
        aps_dN.Bs_B_10um(ij(ii)) = NaN;
        aps_dN.Bs_G_10um(ij(ii)) = NaN;
        aps_dN.Bs_R_10um(ij(ii)) = NaN;
    end
    disp(ii);
end
%% 


figure(2); sb(1) = subplot(2,1,1);plot(serial2doy(aosneph.time(good_1)), aosneph.vars.Bs_B_Dry_Neph3W_1.data(good_1), 'b.',...
    serial2doy(aosneph.time(good_1)), aosneph.vars.Bs_G_Dry_Neph3W_1.data(good_1), 'g.',...
    serial2doy(aosneph.time(good_1)), aosneph.vars.Bs_R_Dry_Neph3W_1.data(good_1), 'r.',...
    serial2doy(aosneph.time(good_10)), aosneph.vars.Bs_B_Dry_Neph3W_1.data(good_10), 'bo',...
    serial2doy(aosneph.time(good_10)), aosneph.vars.Bs_G_Dry_Neph3W_1.data(good_10), 'go',...
    serial2doy(aosneph.time(good_10)), aosneph.vars.Bs_R_Dry_Neph3W_1.data(good_10), 'ro')
legend('neph Bs_B','neph Bs_G','neph Bs_R');
sb(2) = subplot(2,1,2);plot(serial2doy(aps_dN.time(good_1)), aps_dN.Bs_B_1um(good_1), 'b.',...
    serial2doy(aps_dN.time(good_1)), aps_dN.Bs_G_1um(good_1), 'g.',...
    serial2doy(aps_dN.time(good_1)), aps_dN.Bs_R_1um(good_1), 'r.',...
    serial2doy(aps_dN.time(good_10)), aps_dN.Bs_B_10um(good_10), 'bo',...
    serial2doy(aps_dN.time(good_10)), aps_dN.Bs_G_10um(good_10), 'go',...
    serial2doy(aps_dN.time(good_10)), aps_dN.Bs_R_10um(good_10), 'ro');
legend('APS Bs_B','APS Bs_G','APS Bs_R');
linkaxes(sb,'xy');
xlim(xl)
%% 

end
%%
return
%%
% SizeDist_Optics(1.55+0.001i, aps_dN.D.*1000, aps_dN.sdist(2000,:), 550,'cut',5000, 'nephscats',true,'normalized',false);
% 
% 
% ans = 
% 
%     extinction: 20.8826
%     scattering: 20.6761
%     absorption: 0.2065
%       backscat: 1.9137
%       nephscat: 16.8981
%      nephbscat: 1.8906
%            ssa: 0.9901
%           asym: 0.7043
%        forceff: -219.6123