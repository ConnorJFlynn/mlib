function d = rd_pcasp_csv(filename);
% d = rd_pcasp_csv(filename)
% Reads PCASP .csv (text) file.  Not needed much now that we read the full
% data file instead.
if ~exist('filename','var')
    [fname, pname] = uigetfile('*d?.csv');
    filename = [pname, fname];
end
fid = fopen([filename]);
tmp = fgetl(fid);

i = 0;
%%

while ~feof(fid)
    %
    i = i + 1;
    format = ['%d %s %s %d %s %s %d'];
    C = textscan(fid, format,1,'delimiter',',');

    d.probeNumber(i) = C{1};
    d.time(i) = datenum([char(C{2}), ' ', char(C{3})])+double(C{4})/(1000*24*60*60);
    d.stime(i) = datenum([char(C{5}), ' ', char(C{6})])+double(C{7})/(1000*24*60*60);
    format = ['%d'];
    %
    C = textscan(fid, format,1,'delimiter',',');
    d.interval(i) = real(C{1});
    format = ['%n'];
    C = textscan(fid, format,31,'delimiter',',');
    d.d_ch(:,i) = double(C{1});
    format = ['%n %n %n %n %n %n %n %n %n %n %n'];
    C = textscan(fid, format,1,'delimiter',',');
    d.rejectedDofCount(i) = real(C{1});
    d.rejectedATCount(i) = real(C{2});
    d.averageTransit(i) = real(C{3});
    d.FIFOfull(i) = real(C{5});
    d.resetFlag(i) = real(C{5});
    d.ADCoverflow(i) = real(C{6});
    d.backOverflow(i) = real(C{7});
    d.oversizeRejects(i) = real(C{8});
    d.endRejects(i) = real(C{9});
    d.sumOfParticles(i) = real(C{10});
    d.sumOfTransit(i) = real(C{11});
    format = ['%n'];
    C = textscan(fid, format,62,'delimiter',',');
    d.i_ch(:,i) = double(C{1});
    format = ['%n'];
    C = textscan(fid, format,40,'delimiter',',');
    d.b_ch(:,i) = double(C{1});
    format = ['%n'];
    C = textscan(fid, format,64,'delimiter',',');
    d.ipSep(:,i) = double(C{1});
    C = textscan(fid, '%[^\n]',1);
end
fclose(fid);
%%

