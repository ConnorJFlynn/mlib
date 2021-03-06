function d = rd_pcasp_dat(filename);
%d = rd_pcasp_dat(filename);
% d contains entire data file including setup parameters and thresholds
% Also contains thresholds adjusted for gain range and adjAvg averaged
% counts divided by the bin width.
%     d.adjThreshold = d.setup.countThreshold+double(4096*offset);
%     d.adjAvg = d.ch_avg./d.setup.binCountWidth;
if ~exist('filename','var')
    [fid, fname, pname] = getfile('*.txt','pcasp');
    fclose(fid);
    filename = [pname, fname];
elseif exist(filename, 'dir')
    [fid,fname, pname] = uigetfile([filename,filesep,'*.txt'],'pcasp');
    fclose(fid);
    filename = [pname, fname];
end
fid = fopen(filename);
if fid>0
    [pname, fname,ext] = fileparts(filename);
    d.pname = [pname, filesep];
    d.fname = [fname, ext];
    nm = findstr(d.fname, 'nm');
    if ~isempty(nm)
        nm = sscanf(fliplr(sscanf(fliplr(d.fname(1:(nm-1))),'%[0123456789]')),'%g');
        if ~isempty(nm)
            d.PSLnm = nm;
        else
            d.PSLnm = NaN;
        end
    else
        d.PSLnm = NaN;
    end
    d.setup = read_pcasp_setup(fid);
    tmp = fgetl(fid);
    while length(findstr(upper(tmp),'DATA'))<1
        tmp = fgetl(fid);
    end
    i = 0;
    while ~feof(fid)
        try
            i = i +1;
            format = ['%d #%s %d #%s %d %d %*[^\n]'];
            top = 1>0;
            C = textscan(fid, format, 1,'delimiter',',');
            top = 1<0;
            d.probeNumber(i) = C{1};
            d.systemTimestamp(i) = (datenum(C{2},'yyyy-mm-dd HH:MM:SS#'));
            d.systemTimestamp(i) = d.systemTimestamp(i) + double(C{3})/(24*60*60*1000);
            d.probeTimestamp(i) = (datenum(C{4},'yyyy-mm-dd HH:MM:SS#'));
            d.probeTimestamp(i) = d.probeTimestamp(i) + double(C{5})/(24*60*60*1000);
            d.intervalMs(i) = C{6};
            format = ['%d '];
            C = textscan(fid, format, 31,'delimiter',',');
            d.AD(:,i) = C{1};
            %
            %         for ad = 1:31
            %             C = textscan(fid, format, 1,'delimiter',',');
            %             d.AD(ad,i) = C{1};
            %         end
            format = ['%d %d %d %d %d %d %d %d %d %d %d '];
            C = textscan(fid, format, 1,'delimiter',',');
            d.rejectedDofCount(i) = C{1};
            d.rejectedATCount(i) = C{2};
            d.avgTransit(i) = C{3};
            d.FIFOFull(i) = C{4};
            d.resetFlag(i) = C{5};
            d.ADCoverFlow(i) = C{6};
            d.backOverflow(i) = C{7};
            d.oversizeRejects(i) = C{8};
            d.endRejects(i) = C{9};
            d.sumofParticles(i) = C{10};
            d.sumofTransit(i) = C{11};

            format = ['%d '];
            C = textscan(fid, format, d.setup.chCount,'delimiter',',');
            d.ch(:,i) = C{1};

            %         for ch_id = 1:d.setup.chCount
            %             C = textscan(fid, format, 1,'delimiter',',');
            %             d.ch(ch_id,i) = C{1};
            %         end
        catch
            if ~feof(fid)&&top
                disp('bad file?')
                return
            else
                break
            end
        end
    end
    fclose(fid);

    d.ch_avg = mean(d.ch,2);
    d.time = d.systemTimestamp;
    offset = 0;
    if d.setup.range >1
        offset = d.setup.range-1;
    end
    d.adjThreshold = d.setup.countThreshold+double(4096*offset);
    d.adjAvg = d.ch_avg./d.setup.binCountWidth;

end;
d.range = d.setup.range;
d.chCount = d.setup.chCount;
d.userTable = d.setup.userTable;
d.countThreshold = d.setup.countThreshold;
d.binCountWidth = d.setup.binCountWidth;
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
d.ProbeSpecificAirSpeed = C{3};

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
elseif d.userTable==1
    d.userTable = 'B';
end

format = ['%f %f %*[^\n]'];
C = textscan(fid, format, d.chCount,'delimiter',',');
d.countThreshold = C{1};
d.size = C{2};
d.binCountWidth = [d.countThreshold(1); diff(d.countThreshold)];
%     for r = d.range;
%         for n = 1:d.ChCount
%             C = textscan(fid, format, 1,'delimiter',',');
%             d.(['Range',num2str(r),'_Threshold'])(n) = C{1};
%             d.(['Range',num2str(r),'_Size'])(n) = C{2};
%         end
%     end