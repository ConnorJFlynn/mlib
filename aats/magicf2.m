function magic_factor=magicf2(lambda_SPM,response);

%computes magic factor from Solar and Lamp Spectrum

%********* Reads Wehrli 85 Solar Spectrum***************
%Wehrli Spectrum
fid=fopen('d:\beat\data\sun\atlas85.asc');
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun=data(1,:);
 sun       =data(2,:);
fclose(fid);
sun= interp1(lambda_sun,sun,lambda_SPM);
sun_w_response=sun.*response;
x_Wehrli = trapz(lambda_SPM,sun_w_response);

%********* Reads Kuruz-Spectrum***********************************
%fid=fopen('d:\beat\data\sun\sun3.dat');
%line=fgetl(fid);
%line=fgetl(fid);
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun2=data(1,:);
% sun2       =data(2,:);
%fclose(fid);
%sun2=sun2.*lambda_sun2.^2/1e3;
%lambda_sun2=1e7./lambda_sun2;
%i=find(lambda_sun2<=max(lambda_SPM) & lambda_sun2 >= min(lambda_SPM));
%response2= interp1(lambda_SPM,response,lambda_sun2(i));
%sun_w_response=response2.*sun2(i);
%x_Kurucz = -trapz(lambda_sun2(i),sun_w_response);

%sun2= interp1(lambda_sun2,sun2,lambda_SPM);
%sun_w_response=sun2'.*response;
%x_Kurucz = trapz(lambda_SPM,sun_w_response)*0.99446
%x2*0.99446/x1

%********* Reads 15 April 1993 Solar Spectrum of UARS***************
%fid=fopen('c:\beat\data\sun\U_150493.dat');
% line=fgetl(fid);
% line=fgetl(fid);
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun3=data(1,:);
% sun3       =data(2,:)/1e3;
%fclose(fid);
%sun3= interp1(lambda_sun3,sun3,lambda_SPM);
%sun_w_response=sun3'.*response;
%x_UARS_April93 = trapz(lambda_SPM,sun_w_response) 

%********* Reads 29 March 1992 Solar Spectrum of UARS***************
%fid=fopen('c:\beat\data\sun\U_290392.dat');
% line=fgetl(fid);
% line=fgetl(fid);
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun4=data(1,:);
% sun4       =data(2,:)/1e3;
%fclose(fid);
%sun4= interp1(lambda_sun4,sun4,lambda_SPM);
%sun_w_response=sun4'.*response;
%x_UARS_March92 = trapz(lambda_SPM,sun_w_response)

%********* Reads 29 March 1992 Solar Spectrum of ATLAS1***************
%fid=fopen('c:\beat\data\sun\A_290392.dat');
%for i=1:21
% line=fgetl(fid);
%end
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun5=data(1,:);
% sun5       =data(2,:)/1e3;
%fclose(fid);
%sun5= interp1(lambda_sun5,sun5,lambda_SPM);
%sun_w_response=sun5'.*response;
%x_ATLAS1_March92 = trapz(lambda_SPM,sun_w_response)

%********* Reads Thuillier ATLAS-1 Solar Spectrum***************
%fid=fopen('d:\beat\data\sun\solspec.92');
% data=fscanf(fid, '%g %g', [2,inf]);
% lambda_sun6=data(1,:);
% sun6       =data(2,:)/1000;
%fclose(fid);
%sun6= interp1(lambda_sun6,sun6,lambda_SPM);
%sun_w_response=sun6.*response;
%x_SOLSPEC= trapz(lambda_SPM,sun_w_response);

%********* Reads Thuillier ATLAS-1 v9b Solar Spectrum***************
fid=fopen('d:\beat\data\sun\uvvi_v9_b.dat');
 data=fscanf(fid, '%g %g', [2,inf]);
 lambda_sun6=data(1,:);
 sun6       =data(2,:)/1000;
fclose(fid);
sun6= interp1(lambda_sun6,sun6,lambda_SPM);
sun_w_response=sun6.*response;
x_SOLSPEC_v9b= trapz(lambda_SPM,sun_w_response);


%********* ***************
%magic_factor=[x_Wehrli x_Kurucz x_UARS_April93 x_UARS_March92 x_ATLAS1_March92 x_SOLSPEC];
%magic_factor=[x_Wehrli x_Kurucz x_UARS_April93 x_UARS_March92 0 x_SOLSPEC];
magic_factor=[x_SOLSPEC_v9b/x_Wehrli];
%magic_factor=[x_Wehrli/x_Wehrli x_Kurucz/x_Wehrli 0 0 0 0];
%magic_factor=x_Wehrli;


%********* Reads Coefficients for FEL Lamp-Spectrum***************
%[filename,path]=uigetfile('c:\beat\data\lamps\f*.fit', 'Choose a Lamp File', 0, 0);
%fid=fopen([path filename]);
%fid=fopen('c:\beat\data\lamps\f297.fit');
%a=fscanf(fid, '%g', [8,1]);
%fclose(fid);

%wl=lambda_SPM/1000;
%pn=POLYVAL(a(3:8),wl);
%FEL= exp(a(1)+a(2)./wl).*wl.^(-5).*pn;

%FEL_w_response=FEL.*response;
%y= trapz(lambda_SPM,FEL_w_response);
%magic_factor=magic_factor/y;
%end;
