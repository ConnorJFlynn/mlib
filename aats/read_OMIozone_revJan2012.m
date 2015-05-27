%read_OMIozone.m
clear
close all

flag_mission='Ames_2011'; %'Ames_2012'
flag_write='yes'; 

switch flag_mission
    case 'Ames_2011'
        yymmdd_in =[111226:111231];
        iproc_day=ones(1,length(yymmdd_in));
        rlonincenter=-122;
        rlatincenter= 37;
        nbinslat=2;%10;%7;
        nbinslon=2;%10;%5;
        yearin=11;
        path='c:\johnmatlab\OMI_ozone_2011\';
        filewrite='OMI_ozone_summary_2011.txt';
    case 'Ames_2012'
        yymmdd_in =[120101:120108];
        iproc_day=ones(1,length(yymmdd_in));
        rlonincenter=-122;
        rlatincenter= 37;
        nbinslat=2;%10;%7;
        nbinslon=2;%10;%5;
        yearin=12;
        path='c:\johnmatlab\OMI_ozone_2012\';
        filewrite='OMI_ozone_summary_2012.txt';
end

if strcmp(flag_write,'yes')
 fid_write=fopen([path filewrite],'a');
end

latitude=-89.5:1:89.5;
%longitude=-179.375:1.25:179.375;
longitude=-179.5:1:179.5;   %handle new OMI longitude spacing of one degree

idx_dates=find(iproc_day==1);

for jd=idx_dates,
    iyymmdd=yymmdd_in(jd);
    
    %filename=strcat('L3_ozone_omi_2008',sprintf('%04d',imoda),'.txt');
    filename=strcat('L3_ozone_omi_20',sprintf('%06d',iyymmdd),'.txt');
    fid=fopen([path filename]);
    
    %skip 3 lines
    for i=1:3,
        line = fgetl(fid);		%skip end-of-line character
    end
    
    if yearin>=08 %for ARCTAS and later
        for j=1:180,
            kend=25;
            for lines=1:15,
                linedata = fgets(fid);
                if lines==15
                    kend=10;
                end
                datain=linedata(2:kend*3+1);
                for kk=1:kend,
                    ibeg=3*(kk-1)+1;
                    idx=25*(lines-1)+kk;
                    datause(idx)=str2num(datain(ibeg:ibeg+2));
                end
            end
            
            data(:,j)=datause(1,:)';%/10;
        end
        
    else  %before ARCTAS 2008
        
        for j=1:180,
            kend=25;
            for lines=1:12,
                linedata = fgets(fid);
                if lines==12
                    kend=13;
                end
                datain=linedata(2:kend*3+1);
                for kk=1:kend,
                    ibeg=3*(kk-1)+1;
                    idx=25*(lines-1)+kk;
                    datause(idx)=str2num(datain(ibeg:ibeg+2));
                end
            end
            
            data(:,j)=datause(1,:)';%/10;
        end
    end
    
    fclose(fid);
    
    
    latinterp=interp1(latitude,latitude,rlatincenter,'nearest');
    idxlat=find(latitude==latinterp);
    loninterp=interp1(longitude,longitude,rlonincenter,'nearest');
    idxlon=find(longitude==loninterp);
    
    if strcmp(flag_write,'yes')
        fprintf(fid_write,'OMI ozone file: %s\n',filename)
        
        ilonbeg=idxlon-nbinslon;
        ilonend=ilonbeg+9;
        ilonfinal=idxlon+nbinslon;
        nlontot=ilonfinal-ilonbeg+1;
        dnlon=fix(nlontot/10) + 1;
        for jj=1:dnlon,
            klonwr=[ilonbeg:ilonend];
            fprintf(fid_write,'lat/lon: %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f',longitude(klonwr));
            fprintf(fid_write,'\n');
            fprintf(fid_write,'-------- -------- -------- -------- -------- -------- -------- -------- -------- -------- --------\n');
            for jlat=idxlat-nbinslat:idxlat+nbinslat,
                fprintf(fid_write,' %5.1f  %8.0f %8.0f %8.0f %8.0f %8.0f %8.0f %8.0f %8.0f %8.0f %8.0f',latitude(jlat),data(klonwr,jlat));
                fprintf(fid_write,'\n');
            end
            ilonbeg=ilonend+1;
            ilonend=min(ilonbeg+9,ilonfinal);
            if (ilonbeg>ilonfinal) break; end
        end
    end
    
end 

if strcmp(flag_write,'yes')
    fclose(fid_write);
end
