% Read MPLnor file
%%
close('all')
%%

nor = ancload;
nor_new = ancload;
%%


figure; imagesc(serial2Hh(nor.time), nor.vars.height.data, real(log10(nor.vars.backscatter.data))); 
axis('xy'); colormap('jet'); caxis([-3,0]); colorbar;
%
ylim([0,5]); title(datestr(nor.time(1), 'yyyy-mm-dd'))
zoom;

%%
xl = xlim;
%%
blocked = (serial2Hh(nor.time)>xl(1))&(serial2Hh(nor.time)<xl(2));
figure; plot(nor.vars.height.data, mean(nor.vars.backscatter.data(:,blocked),2),'r')
figure; plot(nor_new.vars.height.data, mean(nor_new.vars.backscatter.data(:,blocked),2),'r')


%%
ap_2 = nor.vars.afterpulse_correction.data .* (nor.vars.range.data.^2);
clearsky = (serial2Hh(nor.time)>xl(1))&(serial2Hh(nor.time)<xl(2));
figure; plot(nor.vars.height.data, mean(nor.vars.backscatter.data(:,clearsky),2),'b',...
nor.vars.height.data, mean(nor_new.vars.backscatter.data(:,clearsky),2),'r', ...
nor.vars.range.data,nor.vars.afterpulse_correction.data,'k', ...
nor.vars.height.data, -1*(mean(nor.vars.backscatter.data(:,clearsky),2)-mean(nor_new.vars.backscatter.data(:,clearsky),2)),'k.'); 
axis(v)


%%
figure; plot(nor.vars.range.data, nor.vars.afterpulse_correction.data,'b')

%%

%Adjust axis limits and color bounds to suit.
v = axis;
cv = caxis;
figure; imagesc(serial2Hh(nor.time), nor.vars.height.data, real(log10(nor.vars.backscatter.data))); 
axis('xy'); colormap('jet'); axis(v); caxis(cv); colorbar;
hold('on');
plot(serial2Hh(nor.time), nor.vars.cloud_base_height.data,'.')
%%
% Now zoom into a clear-sky region.
xl = xlim;
subt = (serial2Hh(nor.time)>xl(1)) & (serial2Hh(nor.time)<xl(2));
[atten_bscat,tau, ray_tod] = std_ray_atten(nor.vars.height.data);
r.cal10 = (nor.vars.height.data >= 9.5)&(nor.vars.height.data <= 10.5);
Cal10 = 10^((mean(log10(atten_bscat(r.cal10))) - mean(log10(mean(nor.vars.backscatter.data(r.cal10,subt),2)))));
figure; semilogy(nor.vars.height.data, Cal10*mean(nor.vars.backscatter.data(:,subt),2),'b.',nor.vars.height.data,atten_bscat,'r');

% Plot backscatter 