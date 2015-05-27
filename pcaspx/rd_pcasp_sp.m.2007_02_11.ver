function d = rd_pcasp_sp(filename);
if ~exist('filename','var')
    [fname, pname] = uigetfile('*.sp?');
    filename = [pname, fname];
elseif ~exist(filename, 'file')
    [fname, pname] = uigetfile(filename);
    filename = [pname, fname];
end
fid = fopen(filename);
if fid>0
    [pname, fname,ext] = fileparts(filename);
    d.pname = [pname, filesep];
    d.fname = [fname, ext];
    d.setup = read_pcasp_setup(fid);
end
fclose(fid);

%%

function d = read_pcasp_setup(fid);
format = ['"SETUP %d %*[^\n]'];
C = textscan(fid, format,1,'delimiter',' ,');
d.version = C{1};
format = ['"Probe", %d %*[^\n]'];
C = textscan(fid, format,1,'delimiter',' ,');
d.probe = C{1};
format = ['" %d %*[^\n]'];
C = textscan(fid, format,1,'delimiter',' ,');
d.baud = C{1};
format = ['%d %s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',' ,');
d.calibrate = C{1};
d.liquidWater = length(findstr(upper('true'),upper(char(C{2}))))>0;
format = ['%s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',' ,');
d.enabled = length(findstr(upper('true'),upper(char(C{1}))))>0;
format = ['"%s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter','"');
d.filename = C{1};
format = ['"%s %d %*[^\n] '];
C = textscan(fid, format, 1,'delimiter',',');
d.probeName = C{1};
d.probeType = C{2};
format = ['%s %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.usePitoAir = length(findstr(upper('true'),upper(char(C{1}))))>0;
d.airSpeed = C{2};
d.temperature = C{3};
format = ['%d %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.pressure = C{1};
d.transitReject = C{2};
d.DOFReject = C{3};
format = ['%d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.avgTransitTime = C{1};
d.avgTransitTimeAccept = C{2};
format = ['%d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.displayInterval = C{1};
d.pollingInterval = C{2};
format = ['%d %d %d %d %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.countMethod = C{1};
d.divisorFlag = C{2};
d.divisor = C{3};
d.pumpOn = C{4};
d.COMPort = C{5};
d.TDChannel = C{6};
format = ['%f %f %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.beamDiameter = C{1};
d.DOFLength = C{2};
d.clockSpeed = C{3};
format = ['%s %f %f %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.serialNo = C{1};
d.refractiveIndex = C{2};
d.recoveryCoef = C{3};
format = ['%s %d %s %d %f %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.environmentalSource = length(findstr(upper('true'),upper(char(C{1}))))>0;
d.grndSource = C{2};
d.useFlowMeter = length(findstr(upper('true'),upper(char(C{3}))))>0;
d.fixedFlowRate = C{4};
d.minThreshold = C{5};
format = ['%f %f %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.CASLaserAtten = C{1};
d.twoDArmWidthMM = C{2};
format = ['%s %s %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.auxDigOut = length(findstr(upper('true'),upper(char(C{1}))))>0;
d.rejectBasedOnEndDiode = length(findstr(upper('true'),upper(char(C{2}))))>0;
d.transferParticleLimit = C{3};
d.probeVersion = C{4};
format = ['%d %s %f %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.environmentalInput = C{1};
d.useProbeSpecificAirSpeed = length(findstr(upper('true'),upper(char(C{2}))))>0;
d.probeSpecificAirSpeed = C{3};

format = ['%s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.useNucleiCounter = length(findstr(upper('true'),upper(char(C{1}))))>0;

format = ['%s %s %s %d %d %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.recordFilePacsStandard = length(findstr(upper('true'),upper(char(C{1}))))>0;
d.recordFileCSV = length(findstr(upper('true'),upper(char(C{2}))))>0;
d.recordFile2Dimg = length(findstr(upper('true'),upper(char(C{3}))))>0;
d.commitDataInterval = C{4};
d.minimumSliceCount = C{5};
d.probeResolution = C{6};
d.numberOfDiodes = C{7};

format = ['%s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.totalWater = length(findstr(upper('true'),upper(char(C{1}))))>0;

format = ['%d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.restartRecordInterval = C{1};
d.recordFilenameSuffix = C{2};

format = ['%s %s %d %d %s %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',', ');
d.enableAutoStart = length(findstr(upper('true'),upper(char(C{1}))))>0;
d.enableAutoStop = length(findstr(upper('true'),upper(char(C{2}))))>0;
d.startDelay = C{3};
d.stopSpeed = C{4};
d.recordFilename = C{5};

format = ['%s %f %f %*[^\n]'];
for n = 1:31
    C = textscan(fid, format, 1,'delimiter',',');
    d.auxLabel(n) = C{1};
    d.calcCoeffs(n) = C{2};
    d.offsets(n) = C{3};
end
%Looks like this doesn't contain analog cards because setup skips
%AuxLabels, etc.  Good!
format = ['%s %*[^\n]'];
for n = 1:8
    C = textscan(fid, format, 1,'delimiter',',');
    d.relayLabel(n) = C{1};
end

format = ['%d %d %d %*[^\n]'];
C = textscan(fid, format, 1,'delimiter',',');
d.range = C{1};
d.chCount = C{2};
d.userTable = C{3};
if d.userTable==0
    d.userTable = 'A';
else d.userTable==1
    d.userTable = 'B';
end

format = ['%f %f %*[^\n]'];
for r = 0:3
    for ch_num = [10,20,30,40]
        C = textscan(fid, format, ch_num,'delimiter',',');
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableA']).countThreshold = C{1};
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableA']).size = C{2};
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableA']).binCountWidth = ...
            [d.(['Range',num2str(r),'_',num2str(ch_num),'_tableA']).countThreshold(1),...
            diff(d.(['Range',num2str(r),'_',num2str(ch_num),'_tableA']).countThreshold)];
        C = textscan(fid, format, ch_num,'delimiter',',');
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableB']).countThreshold = C{1};
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableB']).size = C{2};
        d.(['Range',num2str(r),'_',num2str(ch_num),'_tableB']).binCountWidth = ...
            [d.(['Range',num2str(r),'_',num2str(ch_num),'_tableB']).countThreshold(1);...
            diff(d.(['Range',num2str(r),'_',num2str(ch_num),'_tableB']).countThreshold)];
    end
end