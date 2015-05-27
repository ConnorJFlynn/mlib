%tmp script to read raw PSAP data
%The data may be captured with LiveCPD software (lr_ records) or with any 
%serial data grabber.
%NOTE: LiveCPD style data need to be stripped off LiveCPD time stamp

sn='77_complex';
datadir=['D:\data\psap_noise\psap' sn '\'];
raw_data_file=[datadir 'psap' sn '_all.log'];

%one for all channels bad data place holder to be used in output files
bad_data=99999;

%read file
[st1,tr_b,tr_g,tr_r,ref_b,ref_g,ref_r,slpm,f_volt,avg_s,flag,raw_str]=textread(raw_data_file,'%s  %f %f %f %f %f %f %f %d %d %d %s');
%parse PSAP date/time
bb=char(st1);
year=str2num(bb(:,1:2));
if year>50
	year=1900+year;
else
	year=year+2000;
end
mo=str2num(bb(:,3:4));
da=str2num(bb(:,5:6));
hr=str2num(bb(:,7:8));
mi=str2num(bb(:,9:10));
se=str2num(bb(:,11:12));
jday=dayofyear(year,mo,da)+(hr+(mi+se/60)/60)/24;
%prepare string array of raw data
clear bb;
bb=char(raw_str);
for i=1:size(se,1)
	switch se(i)
		case 0
			adr(i)=hex2dec(bb(i,5:6));
			vol(i)=hex2dec(bb(i,8:15));
			sec_e(i)=hex2dec(bb(i,17:20));
		case 1
			sample_blue(i)=hex2dec(bb(i,5:14));
			ref_blue(i)=hex2dec(bb(i,16:25));
			conv_blue(i)=hex2dec(bb(i,27:32));
			over_blue(i)=hex2dec(bb(i,34:35));
			k0=str2num(bb(i,40:44));
			k1=str2num(bb(i,49:53));
		case 2
			sample_green(i)=hex2dec(bb(i,5:14));
			ref_green(i)=hex2dec(bb(i,16:25));
			conv_green(i)=hex2dec(bb(i,27:32));
			over_green(i)=hex2dec(bb(i,34:35));
			spot=str2num(bb(i,42:46));
		case 3
			sample_red(i)=hex2dec(bb(i,5:14));
			ref_red(i)=hex2dec(bb(i,16:25));
			conv_red(i)=hex2dec(bb(i,27:32));
			over_red(i)=hex2dec(bb(i,34:35));
		case {4,8,12}
			adr(i)=hex2dec(bb(i,5:6));
			vol(i)=hex2dec(bb(i,8:15));
			sec_e(i)=hex2dec(bb(i,17:20));
			if lower(bb(i,22))=='f'
				sample_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,22:27));
			else
				sample_dark(i)=hex2dec(bb(i,22:27));
			end
			if lower(bb(i,29))=='f'
				ref_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,29:34));
			else
				ref_dark(i)=hex2dec(bb(i,29:34));
			end
			over_dark(i)=hex2dec(bb(i,36:37));
			reset_time(i,:)=bb(i,39:50);
		case {5,9,13,17}
			sample_blue(i)=hex2dec(bb(i,5:14));
			ref_blue(i)=hex2dec(bb(i,16:25));
			conv_blue(i)=hex2dec(bb(i,27:32));
			over_blue(i)=hex2dec(bb(i,34:35));
			unknown_fl(i)=str2num(bb(i,37:41));
		case {6,10,14,18}
			sample_green(i)=hex2dec(bb(i,5:14));
			ref_green(i)=hex2dec(bb(i,16:25));
			conv_green(i)=hex2dec(bb(i,27:32));
			over_green(i)=hex2dec(bb(i,34:35));
			unknown_fl(i)=str2num(bb(i,37:41));
		case {7,11,15,19}
			sample_red(i)=hex2dec(bb(i,5:14));
			ref_red(i)=hex2dec(bb(i,16:25));
			conv_red(i)=hex2dec(bb(i,27:32));
			over_red(i)=hex2dec(bb(i,34:35));
			unknown_fl(i)=str2num(bb(i,37:41));
		case 16
			adr(i)=hex2dec(bb(i,5:6));
			vol(i)=hex2dec(bb(i,8:15));
			sec_e(i)=hex2dec(bb(i,17:20));
			if lower(bb(i,22))=='f'
				sample_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,22:27));
			else
				sample_dark(i)=hex2dec(bb(i,22:27));
			end
			if lower(bb(i,29))=='f'
				ref_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,29:34));
			else
				ref_dark(i)=hex2dec(bb(i,29:34));
			end
			over_dark(i)=hex2dec(bb(i,36:37));
			unknown_hex(i)=hex2dec(bb(i,39:50));
		case {20,24,28,32,36,40,44,48,52,56}
			adr(i)=hex2dec(bb(i,5:6));
			vol(i)=hex2dec(bb(i,8:15));
			sec_e(i)=hex2dec(bb(i,17:20));
			if lower(bb(i,22))=='f'
				sample_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,22:27));
			else
				sample_dark(i)=hex2dec(bb(i,22:27));
			end
			if lower(bb(i,29))=='f'
				ref_dark(i)=-hex2dec('ffffff')+hex2dec(bb(i,29:34));
			else
				ref_dark(i)=hex2dec(bb(i,29:34));
			end
			over_dark(i)=hex2dec(bb(i,36:37));
		case 21
			sample_blue(i)=hex2dec(bb(i,5:14));
			ref_blue(i)=hex2dec(bb(i,16:25));
			conv_blue(i)=hex2dec(bb(i,27:32));
			over_blue(i)=hex2dec(bb(i,34:35));
			mf0p0=str2num(bb(i,43:46));
		case 22
			sample_green(i)=hex2dec(bb(i,5:14));
			ref_green(i)=hex2dec(bb(i,16:25));
			conv_green(i)=hex2dec(bb(i,27:32));
			over_green(i)=hex2dec(bb(i,34:35));
			mf0p3=str2num(bb(i,43:46));
		case 23
			sample_red(i)=hex2dec(bb(i,5:14));
			ref_red(i)=hex2dec(bb(i,16:25));
			conv_red(i)=hex2dec(bb(i,27:32));
			over_red(i)=hex2dec(bb(i,34:35));
			mf2p0=str2num(bb(i,43:46));
		case {25,29,33,37,41,45,49,53,57}
			sample_blue(i)=hex2dec(bb(i,5:14));
			ref_blue(i)=hex2dec(bb(i,16:25));
			conv_blue(i)=hex2dec(bb(i,27:32));
			over_blue(i)=hex2dec(bb(i,34:35));
		case {26,30,34,38,42,46,50,54,58}
			sample_green(i)=hex2dec(bb(i,5:14));
			ref_green(i)=hex2dec(bb(i,16:25));
			conv_green(i)=hex2dec(bb(i,27:32));
			over_green(i)=hex2dec(bb(i,34:35));
		case {27,31,35,39,43,47,51,55,59}
			sample_red(i)=hex2dec(bb(i,5:14));
			ref_red(i)=hex2dec(bb(i,16:25));
			conv_red(i)=hex2dec(bb(i,27:32));
			over_red(i)=hex2dec(bb(i,34:35));
		otherwise
			disp(['Strange second (' num2str(se(i)) ') in line ' num2str(i)])
	end%switch
end%for i

%make one min average of standard PSAP data
ind=find(se==0);				%find 00 sec
ind=[1; ind];					%add starting index
for ii=1:size(ind,1)-1
	avg_tr_b(ii)=mean(tr_b(ind(ii):ind(ii+1)));
	avg_tr_g(ii)=mean(tr_g(ind(ii):ind(ii+1)));
	avg_tr_r(ii)=mean(tr_r(ind(ii):ind(ii+1)));
			
	avg_ref_b(ii)=mean(ref_b(ind(ii):ind(ii+1)));
	avg_ref_g(ii)=mean(ref_g(ind(ii):ind(ii+1)));
	avg_ref_r(ii)=mean(ref_r(ind(ii):ind(ii+1)));
	
	avg_slpm(ii)=mean(slpm(ind(ii):ind(ii+1)));
	avg_yr(ii)=year(ind(ii));
	avg_mo(ii)=mo(ind(ii));
	avg_da(ii)=da(ind(ii));
	avg_mi(ii)=mi(ind(ii));
	avg_sec(ii)=0;
	avg_jday(ii)=jday(ind(ii));
end
%prepare histogramms of 1-sec and 60-sec data
step=0.025;
edg=-1.0-step/2:step:1.0+step/2;			%bin edges for 60-sec
cent=-1:step:1.0+step;					%bin centers for 60-sec 
hist_b=histc(avg_tr_b,edg);
hist_g=histc(avg_tr_g,edg);
hist_r=histc(avg_tr_r,edg);

step_sec=0.5;
edg_sec=-10.0-step_sec/2:step_sec:10.0+step_sec/2;			%edges for 1 sec
cent_sec=-10:step_sec:10.0+step_sec;
hist_b_sec=histc(tr_b,edg_sec);
hist_g_sec=histc(tr_g,edg_sec);
hist_r_sec=histc(tr_r,edg_sec);

jj=1;
clf;
plot(cent_sec,hist_b_sec./size(tr_b,1).*100,'o-b')
ll{jj}=['1-s bl std=' num2str(std(tr_b),'%1.2f')]; jj=jj+1;
hold on
plot(cent_sec,hist_g_sec./size(tr_g,1).*100,'o-g')
ll{jj}=['1-s gr std=' num2str(std(tr_g),'%1.2f')]; jj=jj+1;
plot(cent_sec,hist_r_sec./size(tr_r,1).*100,'o-r')
ll{jj}=['1-s rd std=' num2str(std(tr_r),'%1.2f')]; jj=jj+1;

plot(cent,hist_b./size(avg_tr_b,2).*100,'.--b')
ll{jj}=['60-s bl std=' num2str(std(avg_tr_b),'%1.3f')]; jj=jj+1;
plot(cent,hist_g./size(avg_tr_g,2).*100,'.--g')
ll{jj}=['60-s gr std=' num2str(std(avg_tr_g),'%1.3f')]; jj=jj+1;
plot(cent,hist_r./size(avg_tr_r,2).*100,'.--r')
ll{jj}=['60-s rd std=' num2str(std(avg_tr_r),'%1.3f')]; jj=jj+1;

set(gca,'color','none','fontsize',16)
set(gca,'tickdir','out')
set(gca,'xminortick','on')
set(gca,'yminortick','on')
set(gca,'xlim',[-6 6])
title({['PSAP SN ' sn ' noise distribution.']; [' Total: ' num2str(size(tr_b,1),'%d') ' sec   [' num2str(size(avg_tr_b,2),'%d') ' min]']});
xlabel({'\sigma [Mm ^-^1]';['Bin size: "1-s"=' num2str(step_sec,'%0.1f') ' [Mm ^-^1]; "60-s"=' num2str(step,'%0.3f') ' [Mm ^-^1]']});
ylabel('Occurrence [%]');
leg=legend(ll,'fontsize',16,'color','none');
clear ll;
plot([-std(tr_b) -std(tr_b)],get(gca,'ylim'),'--k');
plot([std(tr_b) std(tr_b)],get(gca,'ylim'),'--k');
