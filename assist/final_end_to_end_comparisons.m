%%
clear
%%
chA_file = getfullname_('*.mat','assist_int', 'Select Andre''s file');
chA_edgar = loadinto(chA_file);
chA  = repack_edgar(chA_edgar);

% chA_file_re = getfullname_('*.mat','assist_int', 'Select Andre''s file');
% chA_edgar_re = loadinto(chA_file_re);
% chA_re  = repack_edgar(chA_edgar_re);

% chA_file_im = strrep(chA_file_re,'real','ima');
% chA_edgar_im = loadinto(chA_file_im);
% chA_im  = repack_edgar(chA_edgar_im);
% 
% chA_file_abs = strrep(chA_file_re,'.real','');
% chA_edgar_abs = loadinto(chA_file_abs);
% chA_abs  = repack_edgar(chA_edgar_abs);
%%
figure; plot(chA.x, [chA.y(1,:)-chA_re.y] ,'-') 
legend('chA old', 'chA new')
%%
chB_edgar = loadinto(strrep(chA_file,'_chA_','_chB_'));
chB_  = repack_edgar(chB_edgar);
%%
figure; plot(chA_.x, chA_.y, '-');
%%
figure; plot(assist.chB.cxs.x, [abs(chA_re.y(1,:)+i*chA_im.y(1,:))-chA_abs.y(1,:)] ,'-') 
legend('abs(re+imag)-abs')
%% Now plot calibrated spectra without FFOV correction
in = find(assist.logi.HBB_F	);
figure; plot(assist.chB.cxs.x, [chB.y(1,:)] ,'-') 

%%
plots_default;
figure; 
plot(assist.chB.cxs.x,abs(mean(assist.chB.cxs.y(in(1:6),:)))- chA.y(1,:), 'r-');
legend('uncalibrated CH HBB real')
grid('on');
%%
plots_default;
figure; 
plot(assist.chA.cxs.x,mean(abs(assist.chA.cxs.y(in(1:6),:))), 'k-',assist.chA.cxs.x, chA_.y(1,:), 'b-');
legend('my uncalibrated real(mean(CH HBB))')
grid('on');
%%
[pname, fname, ext] = fileparts(chA_file);
title(['Edgar file: ',fname, ext],'interp','none')