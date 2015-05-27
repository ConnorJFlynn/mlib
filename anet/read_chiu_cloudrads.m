function cldrad = read_chiu_cloudrads(infile)

if ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname_('*.*','cloudrad');
end
fid = fopen(infile);
tmp = [];
while isempty(tmp)&&~feof(fid)
start = ftell(fid);
tmp = fgetl(fid);
end
fseek(fid, start,'bof');
% First line: 26:04:2011,18:16:18,359,144,875,731,254,570,1429,606,3462,2872,1002,2250,15.8,calibrations->,0.023643,0.003427,0.015113,0.022279,0.074466,0.035358,0.005941,0.000861,0.003797,0.005597,0.018725,0.008870,Solar_Constants->,0.692841,0.228215,0.936925,1.525828,1.844874,1.955499

block = textscan(fid,[repmat('%d',[1,3]), repmat('%d',[1,3]), repmat('%f',[1,12]), '%f', '%s',repmat('%f',[1,12]),'%s',repmat('%f',[1,6])],'delimiter',':,');
fclose(fid);
cldrad.wavelength = [1020, 1640, 870 , 675 , 440 , 500 ]; % Really?  Non-monotonic
cldrad.ESR = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = [];
block(end) = [];
% deleted 6 Solar_Constants and string: Solar_Constants->,0.692841,0.228215,0.936925,1.525828,1.844874,1.955499
% 26:04:2011,18:16:18,359,144,875,731,254,570,1429,606,3462,2872,1002,2250,15.8,calibrations->,0.023643,0.003427,0.015113,0.022279,0.074466,0.035358,0.005941,0.000861,0.003797,0.005597,0.018725,0.008870,
cldrad.skycal = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
% deleted 6 skycals: 0.005941,0.000861,0.003797,0.005597,0.018725,0.008870
% 26:04:2011,18:16:18,359,144,875,731,254,570,1429,606,3462,2872,1002,2250,15.8,calibrations->,0.023643,0.003427,0.015113,0.022279,0.074466,0.035358
cldrad.suncal = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
block(end) = [];
% deleted: 6 suncals and string: calibrations->,0.023643,0.003427,0.015113,0.022279,0.074466,0.035358,

% 26:04:2011,18:16:18,359,144,875,731,254,570,1429,606,3462,2872,1002,2250,15.8
cldrad.head_temp_C = block{end}; block(end) = [];
% deleted head temp
cldrad.skyzen = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
cldrad.sunzen = [block{end-5},block{end-4},block{end-3},block{end-2},block{end-1},block{end}];
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];
cldrad.time = datenum(double([block{3},block{2},block{1}, block{4},block{5},block{6}]));
block(end) = [];block(end) = [];block(end) = [];block(end) = [];block(end) = []; block(end) = [];

cldrad.skyrad = 0.01.*cldrad.skyzen .* cldrad.skycal;
cldrad.sunrad = 0.01.*cldrad.sunzen .* cldrad.suncal;
% Supposedly in units 'W/m/sr/micron', but I think that is /nm
cldrad.skyrad = 1000 .* cldrad.skyrad;
cldrad.sunrad = 1000 .* cldrad.sunrad;

cldrad.skyTr = cldrad.skyrad ./ cldrad.ESR;
cldrad.sunTr = cldrad.sunrad ./ cldrad.ESR;
%%
[cldrad.wavelength, wi] = sort(cldrad.wavelength);
cldrad.skyrad= cldrad.skyrad(:,wi);
cldrad.sunrad= cldrad.sunrad(:,wi);
cldrad.skyTr = cldrad.skyTr(:,wi);
cldrad.sunTr = cldrad.sunTr(:,wi);
figure; plot(cldrad.time, cldrad.skyTr,'.');
legend( '440 nm', '500 nm', '675 nm', '870 nm','1020 nm', '1640 nm');

datetick('keeplimits')

xlabel('date mm/dd');ylabel('normalized radiance')
%%
return

