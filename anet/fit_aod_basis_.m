function [aod_fit, Ks,out_modes] = fit_aod_basis(wl, aod, wl_out);
% aod_fit = fit_aod_basis(wl, aod,wl_out);
% wl should be in nm and Mx1 or 1xM
% aod should be Mx1 or 1xM or MxN with M matchin wl
% wl_out should be Nx1 or 1xN
% Fits supplied AOD as a combination of log_aod basis vectors at selected
% wavelengths and returns over extended
% Testing with new basis from observed anet PDFs in vmr and std

if ~any(wl)>100
    wl = wl*1000;
end

wl_size = size(wl);
if size(wl,1)==1&&size(wl,2)>1
    wl = wl'; 
end
if size(aod,1)==1&&size(aod,2)>1    
    aod = aod'; 
end
if ~isavar('wl_out')
    wl_out = wl;
    wl_out_size = wl_size;
else
    wl_out_size = size(wl_out);
end
if size(wl_out,1)==1 && size(wl_out,2)>1
    wl_out = wl_out';
end
if ~any(wl_out)>100
    wl_out = wl_out * 1000;
end
aod_mode = load([strrep(which('fit_aod_basis.m'),'fit_aod_basis.m','aod_SD_mode.mat')]);

% Seems to work OK for MFRSR + anetmode.
sub_modes = aod_mode.log_modes; 
 sub_modes = sub_modes./(ones(size(sub_modes,1),1)*max(sub_modes));
% sub_i = [2:2:length(aod_mode.vmr)];
% sub_modes = sub_modes(:,sub_i);
log_modes = interp1(aod_mode.log_wl, sub_modes,log(wl),'linear','extrap');

if size(aod,2)==1 % then we also have just one AOD vector)
   % Maybe try iteratively excluding small Ks, and outlier points?
   done = false; good = true(1,size(log_modes,2)); good_ii = find(good);
   while ~done && length(good_ii)>1
       Ks = fit_it_2(log(wl), log(aod), log_modes(:,good_ii));
       nKs = exp(Ks)./max(exp(Ks));
       [minKs,min_ii] = min(nKs);
       if minKs<1e-5
           good_ii(min_ii) = []; 
       else
           done = true;
       end
   end
    
    slog_modes = interp1(aod_mode.log_wl, sub_modes(:,good_ii),log(wl_out),'linear','extrap');
    log_aod_fit = slog_modes*Ks';
    aod_fit = exp(log_aod_fit);
    %     figure_(2020); plot(wl, aod, 'r*',wl_out, aod_fit,'-kx'); logx; logy
else %We have one AOD vector per time
    Ks(t,:) = -inf*ones(size(aod,2),size(log_modes,2)); %fit_it_2(log(wl), log(aod(:,t)), log_modes);
    for t = size(aod,2):-1:1        
        done = false; good = true(1,size(log_modes,2)); good_ii = find(good);
        while ~done && length(good_ii)>1
            Ks_ = fit_it_2(log(wl), log(aod), log_modes(:,good_ii));
            nKs = exp(Ks_)./max(exp(Ks));
            [minKs,min_ii] = min(nKs);
            if minKs<1e-5
                good_ii(min_ii) = [];
            else
                done = true;
            end
        end
        Ks(t,good_ii) = Ks_;
    end
    log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl_out),'linear','extrap');
    log_aod_fit = log_modes*Ks';
    aod_fit = exp(log_aod_fit);
end
out_modes = log_modes(:,good_ii);
if any(wl_out_size ~= size(wl_out))
    aod_fit = aod_fit';
end

%  figure_(2020); plot(wl, aod, 'r*',wl_out, aod_fit,'-kx'); logx; logy

% bins = unique(aod_mode.bin_radius(:));
% md_PSD = 0.*ones(length(Ks),length(bins));
% for k = 1:length(Ks)
%     md_PSD(k,:) = interp1(aod_mode.bin_radius(k,:),exp(Ks(k)).*aod_mode.PSD(k,:), bins);
% end
% md_PSD(isnan(md_PSD))= 0;
% PSD = sum(md_PSD); PSD(PSD==0) = NaN;
% figure; plot(1000.*bins, PSD,'-o');logx; logy
% xlabel('bin radius [um]');

% figure; loglog(wl, aod, 'o-',wl_out, aod_fit,'k-');
% figure; plot(exp(aod_mode.log_wl), exp(aod_mode.log_modes), '-'); logy; logx
return