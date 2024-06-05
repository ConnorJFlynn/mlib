function twst = pol_twst(in_file);

% Developed 2024.01.29 from Pol_Ze_no_45 to document polarization sensitivity of TWST 10
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST pol test file');
end
if isstruct(in_file)&&~empty(in_file)&&isafile(in_file{1})
   in_file = in_file{1};
end

twst = twst4_to_struct(in_file); 

figure; plot([1:length(twst.time)], twst.zenrad_A(1000,:),'*'); ax(1) = gca; legend('ch A');
figure; plot([1:length(twst.time)], twst.zenrad_B(50,:),'r*'); ax(2) = gca; legend('ch B')
linkaxes(ax,'x');
%ids  [     1    2    3    4    5    6     7     8     9     10    11    12    13    14    15    16    17    18    19     ];   
deg = [-1 0 0 0 20 0 40 0 60 0 80 0 100 0 120 0 140 0 160 0 180 0 200 0 220 0 240 0 260 0 280 0 300 0 320 0 340 0 360 0 -1];
degs = [0 20 40 60 80 100 120 140 160 180 200 220 240 260 280  300 320 340 360];
deg_i= 1+ 5.*[0:40];
deg_j = deg_i(2:end)-1; deg_j(end+1) = deg_j(end) + 5;
base = [1:2:39];
rots = base(1:end-1)+1;
clear A_base B_base A_rots B_rots
   A_base(:,length(base)) = mean(twst.zenrad_A(:,1+5.*base(end)+[1:5]),2);
   B_base(:,length(base)) = mean(twst.zenrad_B(:,1+5.*base(end)+[1:5]),2);
for i = length(rots):-1:1
   A_base(:,i) = mean(twst.zenrad_A(:,1+5.*base(i)+[1:5]),2);
   B_base(:,i) = mean(twst.zenrad_B(:,1+5.*base(i)+[1:5]),2);
   A_rots(:,i) = mean(twst.zenrad_A(:,1+5.*rots(i)+[1:5]),2)./mean(A_base(:,i:i+1),2);
   B_rots(:,i) = mean(twst.zenrad_B(:,1+5.*rots(i)+[1:5]),2)./mean(B_base(:,i:i+1),2);
end
figure; plot(degs, A_rots(450:10:750,:),'-');
figure; plot(degs, B_rots(20:10:100,:),'-')

Tr = A_rots';

Tr_ifft = ifft(Tr,[],1);
Tr_ifft(2,:) = 0;
Tr_ifft(end,:) = 0;
Tr_fft = fft(Tr_ifft,[],1);
Tr_fft = real(Tr_fft)-ones([size(Tr_fft,1),1])*mean(real(Tr_fft));

figure; lines = plot([0:20:180], 100.*Tr_fft(1:10,[100:20:1500]),'-'); colormap('jet'); recolor(lines,twst.wl_A([100:20:1500])); 
xlabel('polarizer orientation [degrees]'); ylabel('variation [%]'); colorbar

% figure; lines = plot([0:20:360], Tr_fft,'-'); colormap('jet'); recolor(lines,pol.nm); title(exp_name);
% xlabel('polarizer orientation [degrees]'); ylabel('variation [%]'); colorbar
saveas(gcf,[pname, exp_name,'_vs_deg.fig']);
saveas(gcf,[pname, exp_name,'_vs_deg.png']);
jej = [jet; flipud(jet)]; jej = [jej; jej];
figure; lines = plot(twst.wl_A, 100.*Tr_fft','-'); 
colormap(jej)
 recolor(lines,[0:20:360]); 
colormap(jet);
colorbar
caxis([0,90])
xlabel('wavelength [nm]'); ylabel('variation [%]'); colorbar
saveas(gcf,[pname, exp_name,'_vs_nm.fig']);
saveas(gcf,[pname, exp_name,'_vs_nm.png']);