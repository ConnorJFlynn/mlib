function he_comp = proc_sashe_1s(he,nir);
% he_comp = proc_he_1s(he, nir);
% processes sashe shadowband cycle to produce direct and diffuse components
% Implements two approaches (mean_sb - blocked) vs (max_sb - min_sb)
% And a combination based on whether difference between side bands is small
% 
%% 
if ~isavar('he') he = rd_SAS_raw(getfullname('*vis_1s*','sashevis')); end
if isfield(he,'wl')
    wl = he.wl;
    tint_vis = he.tint;
    rate = he.spec ./ (tint*ones(size(wl)))
    if isavar('nir')&&isfield(nir,'wl')
        wl = [wl nir.wl];
        rate = [rate nir.spec ./ (nir.tint*ones(size(nir.wl)))];
        tint_nir = nir.tint;
    end
    hemisp_ = he.Tag==4;
    sideA_ = he.Tag==6;
    blocked_= he.Tag==8; blocked_ii = find(blocked_);
    sideB_ = he.Tag==10;

    good_blk = sideA_(blocked_ii-1) & sideB_(blocked_ii+1);
    blocked_(blocked_ii(~good_blk)) = false;
    blocked_ii = find(blocked_);
    
%     sbz = rate(blocked_,:);
%     sba = rate(blocked_ii-1,:); sbb = rate(blocked_ii+1,:);
%     dark = rate(blocked_ii-3,:);
%     toth_raw = rate(blocked_ii-2,:);
%     pix = interp1(wl, [1:length(wl)],555,'nearest');
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength')
    wl = he.vdata.wavelength';
    tint_vis = he.vdata.integration_time';
    rate = he.vdata.spectra./(ones(size(he.vdata.wavelength))*he.vdata.integration_time); rate = rate';
    if isavar('nir')&&isfield(nir,'vdata')&&isfield(nir.vdata,'wavelength')
        wl = [wl, nir.vdata.wavelength'];
        tint_nir = nir.vdata.integration_time';
        rate = [rate ,(nir.vdata.spectra./(ones(size(nir.vdata.wavelength))*nir.vdata.integration_time))'];         
    end
    hemisp_ = he.vdata.tag==4;
    sideA_ = he.vdata.tag==6;
    blocked_= he.vdata.tag==8; blocked_ii = find(blocked_);
    sideB_ = he.vdata.tag==10;

    if blocked_ii(end)== length(sideB_)
        blocked_ii(end) = [];
    end
    good_blk = sideA_(blocked_ii-1) & sideB_(blocked_ii+1);
    blocked_(blocked_ii(~good_blk)) = false;
    blocked_ii = find(blocked_);
    
%     sbz = rate(blocked_,:);
%     sba = rate(blocked_ii-1,:); sbb = rate(blocked_ii+1,:);
%     dark = he.vdata.spectra(blocked_ii-3,:);
%     toth_raw = he.vdata.spectra(blocked_ii-2,:);

end
    if blocked_ii(end)== length(sideB_)
        blocked_ii(end) = [];
    end
    sbz = rate(blocked_,:);
    sba = rate(blocked_ii-1,:); 
    sbb = rate(blocked_ii+1,:);
    dark = rate(blocked_ii-3,:);
    toth_raw = rate(blocked_ii-2,:)-dark;
    pix = interp1(wl(1:1000), [1:1000],555,'nearest');
%  %this pixel is near the maximum solar brightness
for b = length(blocked_ii):-1:1
    abz = [sba(b,pix),sbb(b,pix),sbz(b,pix)];
    [max_b,max_i] = sort(abz);
%     good_band(b) = abs(abz(1)-abz(2))<2.*sqrt(abz(1));% as tho photon counts, possion distr.  Not really true.
    abz = [sba(b,:);sbb(b,:);sbz(b,:)];    
    sb_avg(b,:) = mean([sba(b,:);sbb(b,:)]); 
    sb_min(b,:) = abz(max_i(1),:);
    sb_max(b,:) = abz(max_i(3),:);
end
if size(sb_avg,1)>size(sbz,1)
    sb_avg(size(sbz,1)+1:end,:)=[];
elseif size(sbz,1)>size(sb_avg,1)
    sbz(size(sb_avg,1)+1:end,:) = [];
end

dirh_raw_old = sb_avg-sbz;
dirh_raw_new = sb_max-sb_min;
% dirh_raw_comb =  dirh_raw_old .* (double(good_band')*ones(size(wl))) + ...
%     dirh_raw_new .* (double(~good_band')*ones(size(wl)));
difh_raw_new = toth_raw - dirh_raw_new;
difh_raw_old = toth_raw - dirh_raw_old;
% difh_raw_comb = toth_raw - dirh_raw_comb;
he_comp.time = he.time(blocked_ii);
% he_comp.good_band = good_band;
he_comp.wl = wl;
he_comp.dark = dark;
he_comp.th_raw = toth_raw;
he_comp.sba = sba;
he_comp.sbb = sbb; 
he_comp.sbz = sbz; 
he_comp.sb_avg = sb_avg; 
he_comp.sb_min = sb_min;
he_comp.sb_max = sb_max;
he_comp.dirh_raw_old = dirh_raw_old;
he_comp.dirh_raw_new = dirh_raw_new;
% he_comp.dirh_raw_comb = dirh_raw_comb;
he_comp.difh_raw_old = difh_raw_old;
he_comp.difh_raw_new = difh_raw_new;
% he_comp.difh_raw_comb = difh_raw_comb;
pixel = interp1(he.vdata.wavelength, [1:length(he.vdata.wavelength)],[415,500,615,673,870],'nearest');
figure; plot(he_comp.time,[ he_comp.dirh_raw_old(:,pixel(2)),he_comp.dirh_raw_new(:,pixel(2))],'-')
legend('old','new') 
return
