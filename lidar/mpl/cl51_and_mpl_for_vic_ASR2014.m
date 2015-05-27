function cl51_and_mpl_for_vic_ASR2014
%%
plots_vic;
vc51 = ancload([getfullname_('sgpvc*.cdf','vcl')]);
%%
fig1 = figure; imagesc(serial2Hh(vc51.time), vc51.vars.range.data./1000, real(log10(vc51.vars.backscatter.data))); axis('xy');
title(['Vaisala Ceilometer CL51 Backscatter: ',datestr(vc51.time(1), 'yyyy/mm/dd')]);
xlabel('time [UTC]'); 
ylabel('height [km AGL]');
hold('on'); 
blah = plot(serial2Hh(vc51.time), vc51.vars.third_cbh.data./1000, 'wo',serial2Hh(vc51.time), vc51.vars.second_cbh.data./1000, 'ko',...
    serial2Hh(vc51.time), vc51.vars.first_cbh.data./1000, 'ko'); 
set(blah, 'markersize',4);
set(blah(3), 'MarkerFaceColor',[0, 0 0]);
set(blah(3), 'MarkerEdgeColor','none');
set(blah(2), 'MarkerFaceColor',[.5, .5 .5]);
set(blah(2), 'MarkerEdgeColor','none');
set(blah(1), 'MarkerEdgeColor',[.8, .8, .8], 'MarkerFaceColor',[1 1 1], 'MarkerSize',8 );
hold('off');
legend('third CBH','second CBH','first CBH');
caxis([-.5,3.5])
zoom('on')
ax(1) = gca; 


pos = [ 88         162        1664         702];
outpos = [ -0.0585         0    1.0972    1.0000];
set(gcf,'position',pos);
set(gca,'outerposition',outpos);




%%

 mplps = ancload(getfullname_(['sgpmplpolfs*.',datestr(vc51.time(1),'yyyymmdd'),'*.cdf'],'vcl'));
 %
 copol = mplps.vars.signal_return_co_pol.data - ones(size(mplps.vars.range.data))*mplps.vars.background_signal_co_pol.data;
copol_ol = ones(size(mplps.vars.range.data));

ol_ = mplps.vars.range.data>= mplps.vars.overlap_correction_heights.data(1) &mplps.vars.range.data<= mplps.vars.overlap_correction_heights.data(end);
copol_ol(ol_) = interp1(mplps.vars.overlap_correction_heights.data, mplps.vars.overlap_correction.data, mplps.vars.range.data(ol_),'nearest');
copol = copol .* (copol_ol*ones(size(mplps.time)));
r2 = mplps.vars.range.data.^2;
r2(mplps.vars.range.data<0) = NaN;
copol = copol .* (r2*ones(size(mplps.time)));
[atten_bscat] = std_ray_atten(mplps.vars.range.data, .532);
%%
fig2=figure; imagesc(serial2Hh(mplps.time), mplps.vars.range.data, real(log10(copol./(atten_bscat*ones(size(mplps.time)))))-26.5); ...
    caxis([0,2.5]); axis('xy');
set(gcf,'position',pos);set(gca,'outerposition',outpos);
% hold('on'); 
% plot(serial2Hh(vc51.time), vc51.vars.first_cbh.data./1000, 'x',serial2Hh(vc51.time), vc51.vars.second_cbh.data./1000, 'o',...
%     serial2Hh(vc51.time), vc51.vars.third_cbh.data./1000, 's'); 
% hold('off');
ax(2) = gca;
xlabel('time [UTC]'); 
ylabel('height [km AGL]')
title(['MPL Attenuated Backscatter Fraction: ',datestr(mplps.time(1),'yyyy/mm/dd')]);
vc_file = [getfullname_(['sgpceilpblhtC1.a0.*',datestr(vc51.time(1),'yyyymmdd'),'*.cdf'],'vcl')];

if ~isempty(vc_file)
    vc_pbl = ancload(vc_file);
    hold('on');
    blah = plot(serial2Hh(vc_pbl.time), vc_pbl.vars.bl_height_3.data./1000, 'ko',...
        serial2Hh(vc_pbl.time), vc_pbl.vars.bl_height_2.data./1000, 'ro',...
        serial2Hh(vc_pbl.time), vc_pbl.vars.bl_height_1.data./1000, 'wo');
    set(blah, 'markersize',4);
    set(blah(3), 'MarkerFaceColor',[.2,.2,.3]);
    set(blah(2), 'MarkerFaceColor',[.5, .5 .5]);
    set(blah(1), 'MarkerFaceColor',[.8, .8, .8]);
set(blah, 'MarkerEdgeColor','none')
legend('layer 3','layer 2','layer 1');
    hold('off');
end
zoom('on')

linkaxes(ax,'xy')
set(gcf,'position',pos);
set(gca,'outerposition',outpos);
ylim([0,15]);

fig3 = figure; imagesc(serial2Hh(vc_pbl.time), vc_pbl.vars.range.data./1000, real(log10(vc_pbl.vars.backscatter.data))); axis('xy');
title(['Vaisala Ceilometer CL31 Backscatter: ',datestr(vc_pbl.time(1), 'yyyy/mm/dd')]);
xlabel('time [UTC]'); 
ylabel('height [km AGL]');
hold('on'); 
blah = plot(serial2Hh(vc_pbl.time), vc_pbl.vars.third_cbh.data./1000, 'wo',serial2Hh(vc51.time), vc_pbl.vars.second_cbh.data./1000, 'ko',...
    serial2Hh(vc_pbl.time), vc_pbl.vars.first_cbh.data./1000, 'ko'); 
set(blah, 'markersize',4);
set(blah(3), 'MarkerFaceColor',[0, 0 0]);
set(blah(3), 'MarkerEdgeColor','none');
set(blah(2), 'MarkerFaceColor',[.5, .5 .5]);
set(blah(2), 'MarkerEdgeColor','none');
set(blah(1), 'MarkerEdgeColor',[.8, .8, .8], 'MarkerFaceColor',[1 1 1], 'MarkerSize',8 );
hold('off');
legend('third CBH','second CBH','first CBH');
caxis([-.5,3.5])
zoom('on')
ax(1) = gca; 


pos = [ 88         162        1664         702];
outpos = [ -0.0585         0    1.0972    1.0000];
set(gcf,'position',pos);
set(gca,'outerposition',outpos);


OK = menu('Zoom and resize as desired.  Click OK when done.','OK');

saveas(fig1,strrep(vc51.fname,'.cdf','.fig'))
saveas(fig1,strrep(vc51.fname,'.cdf','.png'))
saveas(fig1,strrep(vc51.fname,'.cdf','.emf'))

saveas(fig2,strrep(mplps.fname,'.cdf','.fig'))
saveas(fig2,strrep(mplps.fname,'.cdf','.png'))
saveas(fig2,strrep(mplps.fname,'.cdf','.emf'))


return