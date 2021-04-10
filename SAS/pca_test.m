%%
pname = ['C:\case_studies\SAS\testing_and_characterization\nov3_blue_sky\n_1s\'];
dats = dir([pname, 'sas*.csv']);
%
nir_1s = SAS_read_Albert_csv([pname,dats(1).name]);
%%
for d = 2:length(dats);
   if mod(d,10)==0
      disp(['Reading ',num2str(d)]);
   end
   nir_1s = catsas(nir_1s,SAS_read_Albert_csv([pname,dats(d).name]));
end
save([pname,char(nir_1s.fname),'.mat'],'sas');
%%
nir_1s = loadinto;
%%
[spec_sig0,npcs0,IND0,U0,coefs0] = pcfilter(nir_1s.spec);
nir_1s = strip_sas_nulls(nir_1s);
[spec_sig,npcs,IND,U,coefs] = pcfilter(nir_1s.spec);
%%
t = 0;
n = 0;
%%
n = n + 1;
subplot(3,3,1)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,2)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,3)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,4)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,5)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,6)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,7)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,8)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);
n = n + 1;
subplot(3,3,9)
plot([0:255], U(:,n),'-');
legend(['Component ',num2str(n)]);

%%
%%
pname = ['C:\case_studies\SAS\testing_and_characterization\nov3_blue_sky\vis_1s\'];
dats = dir([pname, 'sas*.csv']);
%
sas = SAS_read_Albert_csv([pname,dats(1).name]);
%%
for d = 2:length(dats);
   sas = catsas(sas,SAS_read_Albert_csv([pname,dats(d).name]));
   if mod(d,10)==0
      disp(['saving ',num2str(d)]);
   end
end
save([pname,char(sas.fname),'.mat'],'sas');
%%
vis_1s = loadinto;
%%
shut = find(vis_1s.Shutter_open_TF==0)
%%
tic
[vis_dark,dark_npcs,dark_IND,dark_U,dark_coefs] = pcfilter(vis_1s.spec(shut,50:10:2000));

toc
%%
shut = find(vis_1s.Shutter_open_TF==0);
figure; plot([1:2048],vis_spec_sig(shut,:),'r-',[1:2048],vis_1s.spec(shut,:),'k-')

%%
U = vis_U;
t = 0;
n = 0;
%%

subplot(5,2,1)
plot([0:2047], vis_1s.spec(1,:),'-');
legend(['Darks']);

subplot(5,2,3)
plot([0:2047], vis_1s.spec(3,:),'-');
legend(['Hemisp']);

subplot(5,2,5)
plot([0:2047], vis_1s.spec(5,:),'-');
legend(['side 1']);

subplot(5,2,7)
plot([0:2047], vis_1s.spec(7,:),'-');
legend(['side 2']);

subplot(5,2,9)
plot([0:2047], vis_1s.spec(9,:),'-');
legend(['blocked']);

subplot(5,2,2)
plot([0:2047], U(:,1),'-');
legend(['Component ',num2str(1)]);

subplot(5,2,4)
plot([0:2047], U(:,2),'-');
legend(['Component ',num2str(2)]);

subplot(5,2,6)
plot([0:2047], U(:,3),'-');
legend(['Component ',num2str(3)]);

subplot(5,2,8)
plot([0:2047], U(:,4),'-');
legend(['Component ',num2str(4)]);

subplot(5,2,10)
plot([0:2047], U(:,5),'-');
legend(['Component ',num2str(5)]);
%%
paeri_pcfilter_driver('C:\case_studies\assist\integration\data_integration\at_SGP\aeri_data\20100722\','C:\case_studies\assist\integration\data_integration\at_SGP\aeri_data\20100722\')
