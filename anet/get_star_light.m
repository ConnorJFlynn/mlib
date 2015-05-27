function star = get_star_light(infile, sky_t, pix)
% Loads a flight AODs and selects only those close to the sky scan at the
% supplied pixels
content = {'t','w','tau_aero','tau_aero_polynomial','tau'};
light = load(infile, content{:});


%%
[ainb,bina] = nearest(sky_t,light.t,.2);% This accepts points within 1/10 of a day or about 2.4 hours
%%
dt = sky_t(end)-sky_t(1);
ddt = (abs(light.t-light.t(bina(1)))<dt)|(abs(light.t-light.t(bina(end)))<dt);

star.t = light.t(ddt);
star.aod = light.tau_aero(ddt,pix);
star.tod = light.tau(ddt,pix);

star.aod_poly = light.tau_aero_polynomial(ddt,:);
%%
% figure; 
% plot(serial2doy(t(ddt)), tau_aero(ddt,pix([2 7])),'.',...
%     serial2doy(t(bina)), tau_aero(bina,pix([2 7])),'go')
%%

return