pname = 'C:\case_studies\assist\data\post_Feb_repair\data_16_feb_2011\';
real_resp = '20110210_185846_chA_SKY1.coad.mrad.mat.gains.mat';
real_offsets = '20110210_185846_chA_SKY1.coad.mrad.mat.offsets.mat';
imag_resp = '20110210_185846_chA_IMA_SKY1.coad.mrad.mat.gains.mat';
imag_offsets = '20110210_185846_chA_IMA_SKY1.coad.mrad.mat.offsets.mat';

real_resp = repack_edgar([pname,real_resp]); 
real_offsets = repack_edgar([pname,real_offsets]); 

imag_resp = repack_edgar([pname,imag_resp]); 

imag_offsets = repack_edgar([pname,imag_offsets]); 

%%
figure; 
ax(1) = subplot(2,1,1);
plot(real_resp.x, [real_resp.y(1,:);imag_resp.y(1,:)],'-');
title('Your responsivity');
legend('real','imag');
ax(2) = subplot(2,1,2);
plot(real_offsets.x, [real_offsets.y(1,:);imag_offsets.y(1,:)],'-')
title('Your offset in cts');
legend('real','imag');

linkaxes(ax,'x');
%%
resp = real_resp.y + 1i.*imag_resp.y;
offset_cts = real_offsets.y + 1i.*imag_offsets.y;
offset_ru = offset_cts ./ resp;


real_off_ru = real_offsets.y./real_resp.y - imag_offsets.y./imag_resp.y;
imag_off_ru = 1i.*(real_offsets.y./imag_resp.y + imag_offsets.y./real_resp.y);


%%
figure; 
axx(1) = subplot(3,1,1);
plot(real_resp.x, [real_resp.y(1,:);imag_resp.y(1,:)],'-');
title('Responsivity');
legend('real','imag');
axx(2) = subplot(3,1,2);
plot(real_offsets.x, [real_offsets.y(1,:);imag_offsets.y(1,:)],'-')
title('Offset_cts');
legend('real','imag');
axx(3) = subplot(3,1,3);
plot(real_offsets.x, [real(offset_ru(1,:));imag(offset_ru(1,:))],'-')
title('Offset_ru');
lg = legend('real_off_ru','imag_off_ru');
set(lg,'interp','none');

linkaxes(axx,'x');
xlim(xl)
%%

