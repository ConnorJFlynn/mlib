function coeff=read_taucoeff()
global coeff;
global path_prog

% path='C:\Documents and Settings\Administrator\Desktop\matlab_fastforwardmodel\';
path=path_prog;
section=['1','2'];
speci=['dry','wet','ozo'];
nl=[60,40,60];
nx=[5,10,10];
nb=[3010,2574];
drycoefffn=[path,'g60coef',section(1),'.',speci(1:3),'.len'];
wetcoefffn=[path,'g60coef',section(1),'.',speci(4:6),'.len'];
ozncoefffn=[path,'g60coef',section(1),'.',speci(7:9),'.len'];

fid1=fopen(drycoefffn,'r');
fid2=fopen(wetcoefffn,'r');
fid3=fopen(ozncoefffn,'r');
dry_coeff1=fread(fid1,'float');
dry_coeff1=reshape(dry_coeff1,[nx(1) nl(1) nb(1)]);
wet_coeff1=fread(fid2,'float');
wet_coeff1=reshape(wet_coeff1,[nx(2) nl(2) nb(1)]);
ozn_coeff1=fread(fid3,'float');
ozn_coeff1=reshape(ozn_coeff1,[nx(3) nl(3) nb(1)]);
drycoefffn=[path,'g60coef',section(2),'.',speci(1:3),'.len'];
wetcoefffn=[path,'g60coef',section(2),'.',speci(4:6),'.len'];
ozncoefffn=[path,'g60coef',section(2),'.',speci(7:9),'.len'];
fclose(fid1);
fclose(fid2);
fclose(fid3);
fid1=fopen(drycoefffn,'r');
fid2=fopen(wetcoefffn,'r');
fid3=fopen(ozncoefffn,'r');
dry_coeff2=fread(fid1,'float');
dry_coeff2=reshape(dry_coeff2,[nx(1) nl(1) nb(2)]);
wet_coeff2=fread(fid2,'float');
wet_coeff2=reshape(wet_coeff2,[nx(2) nl(2) nb(2)]);
ozn_coeff2=fread(fid3,'float');
ozn_coeff2=reshape(ozn_coeff2,[nx(3) nl(3) nb(2)]);
fclose(fid1);
fclose(fid2);
fclose(fid3);

dry_coeff=cat(3,dry_coeff1,dry_coeff2(:,:,45:2574));
wet_coeff=cat(3,wet_coeff1,wet_coeff2(:,:,45:2574));
ozn_coeff=cat(3,ozn_coeff1,ozn_coeff2(:,:,45:2574));

coeff.dry=dry_coeff;
coeff.wet=wet_coeff;
coeff.ozn=ozn_coeff;



