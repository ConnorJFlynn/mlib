function cldrad = read_chiu_cloudrad_raw(infile)

if ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname_('*.*','cloudrad');
end
fid = fopen(infile);
tmp = [];
while isempty(tmp)&&~feof(fid)
start = ftell(fid);
tmp = fgetl(fid);
end
% fseek(fid, start,'bof');

% Magic, 
% Date,Time,AUR 1020 nm,AUR 1640 nm,AUR 870 nm,AUR 670 nm,AUR 440 nm,AUR 500 nm,SKY 1020 nm,SKY 1640 nm,SKY 870 nm,SKY 670 nm,SKY 440 nm,SKY 500 nm,Temperature
% first lines 20/5/2013,0:0:0,36,58,51,53,156,177,140,220,196,207,617,701,24.6
f_str = [repmat('%d ',[1,3]), repmat('%d ',[1,3]), repmat('%f ',[1,13])];
block = textscan(fid,f_str,'delimiter',{':',',','/'});
fclose(fid);

blocks = length(block);
last_block = length(block{end});
while length(block{1})~=last_block
    blob = block{blocks-1};
    block(blocks-1) = {blob(1:last_block)};
    blocks = blocks -1;
end
cldrad.wavelength = [1020, 1640, 870 , 675 , 440 , 500 ]; % Really?  Non-monotonic
cldrad.head_temp_C = block{end}; block(end) = [];


cldrad.ESR = [0.692577,0.227753,0.934690,1.539680,1.840763,1.962220];

% deleted 6 Solar_Constants and string: Solar_Constants->,0.692841,0.228215,0.936925,1.525828,1.844874,1.955499
% 26:04:2011,18:16:18,359,144,875,731,254,570,1429,606,3462,2872,1002,2250,15.8,calibrations->,0.023643,0.003427,0.015113,0.022279,0.074466,0.035358,0.005941,0.000861,0.003797,0.005597,0.018725,0.008870,
%> initial: old calibration coefficients are
suncal = [0.016602, 0.002698, 0.018398, 0.040499, 0.046905, 0.030623];
skycal = [0.004163, 0.000676, 0.004607, 0.010134, 0.011824, 0.007663];
% >
% > post deployment: new calibration coefficients are
% >
suncal(2,:) =  [0.019448, 0.003291, 0.022274, 0.047835, 0.056781, 0.036530];
skycal(2,:) = [ 0.004871, 0.000824, 0.005583, 0.011990, 0.014268, 0.009149];

cal_time(1) = datenum('20130512','yyyymmdd');
cal_time(2) = datenum('20130829','yyyymmdd'); cal_time = cal_time';
% deleted head temp
cldrad.skyzen = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
cldrad.sunzen = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
cldrad.time = datenum(double([block{3},block{2},block{1}, block{4},block{5},block{6}]));
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];

mean_time = floor(mean(cldrad.time));
cldrad.skycal = 0.01.*interp1(cal_time, skycal, mean_time,'linear');
cldrad.suncal = 0.01.*interp1(cal_time, suncal, mean_time,'linear');
cldrad.skyrad = cldrad.skyzen .* (ones(size(cldrad.time))*cldrad.skycal(1,:));
cldrad.sunrad = cldrad.sunzen .* (ones(size(cldrad.time))*cldrad.suncal(1,:));
% Supposedly in units 'W/m/sr/micron', but I think that is /nm
cldrad.skyrad = 1000 .* cldrad.skyrad;
cldrad.sunrad = 1000 .* cldrad.sunrad;

cldrad.skyTr = cldrad.skyrad ./ (ones(size(cldrad.time))*cldrad.ESR);
cldrad.sunTr = cldrad.sunrad ./ (ones(size(cldrad.time))*cldrad.ESR);
%%
[cldrad.wavelength, wi] = sort(cldrad.wavelength);
cldrad.skyrad= cldrad.skyrad(:,wi);
cldrad.sunrad= cldrad.sunrad(:,wi);
cldrad.skyTr = cldrad.skyTr(:,wi);
cldrad.sunTr = cldrad.sunTr(:,wi);
figure(555); plot(cldrad.time, cldrad.skyTr,'.');
legend( '440 nm', '500 nm', '675 nm', '870 nm','1020 nm', '1640 nm');
hold('on');
plot(cldrad.time, cldrad.sunTr,'o');
dynamicDateTicks;
hold('off')

xlabel('date mm/dd');ylabel('normalized radiance')
%%
return

