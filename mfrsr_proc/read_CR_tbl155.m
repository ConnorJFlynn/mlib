function mfr = read_CR_tbl155(infile)
% mfr = read_CR_tbl155(infile)

if ~isavar('infile')||~isafile(infile)
infile = getfullname('CR*Table155.dat','CR_tbl155','Select Table155 file');
end

% "TOA5","CR1000XSeries","CR1000X","9285","CR1000X.Std.04.02","CPU:SUNAE5J6BRv2.CR1X","8690","Table155"
% "TIMESTAMP","RECORD","xoset","az","el","al","cosz","cosasz","pamass","vBat","Thead","THTC","Tlogger","Dnadir(1)","Dnadir(2)","Dnadir(3)","Dnadir(4)","Dnadir(5)","Dnadir(6)","Dnadir(7)","Dsun(1)","Deast(2)","Deast(3)","Deast(4)","Deast(5)","Deast(6)","Deast(7)","Dsun(1)","Dsun(2)","Dsun(3)","Dsun(4)","Dsun(5)","Dsun(6)","Dsun(7)","Dwest(1)","Dwest(2)","Dwest(3)","Dwest(4)","Dwest(5)","Dwest(6)","Dwest(7)","kount","khome"
% "TS","RN","sec","deg","deg","deg","--","--","--","Volt","degC","degC","degC","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","mV","--","--"
% "","","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp"
% "2022-06-17 14:10:00",0,3954,97.3,32.47,32.49,0.537,0.537,1.857,12.01796,32.45,83.7,30.84,35.19,81.9,82.6,80.6,77.28,73.68,24.76,35.19,81.6,82.5,80.7,77.32,73.68,24.81,35.24,81.6,82.5,80.8,77.39,73.75,24.85,35.24,81.5,82.5,80.7,77.32,73.73,24.84,253,526


if ~isafile(infile)
  
else
   fid = fopen(infile);
   fmt = ['%s',repmat('%f',[1,42])];
   [A,ind] = textscan(fid, fmt, 'HeaderLines',4,'Delimiter',',');
   mfr.time = datenum(A{1});
   mfr.az = A{4};
   mfr.el = A{5};
   mfr.al = A{6}; % apparent SEL corrected for refraction
   mfr.cosz = A{7};
   mfr.cosasz = A{8}; %apparent cos(sza)
   mfr.pamass = A{9}; % spherical atm
   mfr.vBat = A{10};
   mfr.Thead = A{11};
   mfr.THTC = A{12};
   mfr.Tlogger = A{13};
   mfr.Dnad = NaN([length(mfr.time),7]);
   mfr.Deast = mfr.Dnad; mfr.Dsun = mfr.Dnad; mfr.Dwest = mfr.Dnad;
   mfr.Dnad(:,1) = A{14}; mfr.Dnad(:,2) = A{15};mfr.Dnad(:,3) = A{16};mfr.Dnad(:,4) = A{17};mfr.Dnad(:,5) = A{18};mfr.Dnad(:,6) = A{19};mfr.Dnad(:,7) = A{20};
   mfr.Deast(:,1) = A{21}; mfr.Deast(:,2) = A{22};mfr.Deast(:,3) = A{23};mfr.Deast(:,4) = A{24};mfr.Deast(:,5) = A{25};mfr.Deast(:,6) = A{26};mfr.Deast(:,7) = A{27};
   mfr.Dsun(:,1) = A{28}; mfr.Dsun(:,2) = A{29};mfr.Dsun(:,3) = A{30};mfr.Dsun(:,4) = A{31};mfr.Dsun(:,5) = A{32};mfr.Dsun(:,6) = A{33};mfr.Dsun(:,7) = A{34};
   mfr.Dwest(:,1) = A{35}; mfr.Dwest(:,2) = A{36};mfr.Dwest(:,3) = A{37};mfr.Dwest(:,4) = A{38};mfr.Dwest(:,5) = A{39};mfr.Dwest(:,6) = A{40};mfr.Dwest(:,7) = A{41};
   mfr.kount = A{42};
   mfr.khome = A{43};
   days = [floor(mfr.time(1)):ceil(mfr.time(end))];
   midn = abs(mfr.az)>150;
   for d = length(days):-1:1;
      night_i = find(midn & abs(mfr.time-days(d))<2);
      if length(night_i)>4
         
         I90 = IQ(mfr.Dnad(night_i,2),.05);
%          dark.time(d) = days(d);
         dark.time(d) = mean(mfr.time(night_i(I90)));
         dark.dk(d,:) = mean(mfr.Dnad(night_i(I90),:));
      end
   end

   mfr.dirh = (mfr.Deast+mfr.Dwest)./2 - mfr.Dsun;mfr.dirh(mfr.al<0,:) = NaN;
   mfr.diff = mfr.Dnad - mfr.dirh - interp1(dark.time, dark.dk, mfr.time,'nearest','extrap'); 
   mfr.cosaz = cosd(90-mfr.al);
   mfr.dirn = mfr.dirh./mfr.cosaz; mfr.dirn(mfr.al<0,:) = NaN;
   am_lt_6 = mfr.pamass>.9 & mfr.pamass<6;
   mfr.dirn2dif = mfr.dirn./mfr.diff; mfr.dirn2dif(~am_lt_6,:) = NaN; mfr.dirn2dif(mfr.diff<1) = NaN;
% Based on tests with LP filters:
% filter 1 = 1.625 nm (blue trace, Matlab)
% filter 2 = 415 nm (green trace)
% filter 3 = 500 nm (red trace)
% filter 2 = 615 nm (cyan trace)
% filter 2 = 676 nm (magenta trace)
% filter 2 = 870 nm (yellow trace)
% filter 2 = 940 nm (black trace)



end
end