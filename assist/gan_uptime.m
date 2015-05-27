%%
uptime_file = ['C:\case_studies\assist_uptime\gan\proc.txt'];

% example line:
% -rw-rw-r--   1 dsmgr    data     4256572 Oct  3 23:25 /data/collection/gan/ganassistM1.00/2011_09_30_17_44_57_PROCESSED.piz
fid = fopen(uptime_file);
%%
A = textscan(fid,'%s %d %s %s %d %s %d %s %s')
%%
in.fname = A{9};
in.sizes = A{5};

for f = length(in.sizes):-1:1
    in.time(f) = datenum( fliplr(strtok(fliplr(in.fname{f}),'//')),'yyyy_mm_dd_HH_MM_SS');
    disp(f)
end
%%
in.sizes = double(in.sizes);
figure; plot(in.time, in.sizes./max(in.sizes), 'o'); 
datetick('keeplimits')
%%

inday.time = (floor(min(in.time)):floor(max(in.time)));
for t = length(inday.time)-1:-1:1
    inday.files(t) = sum(in.time>=inday.time(t)&in.time<inday.time(t+1));
end
% inday.files(inday.files>80) = inday.files(inday.files>80)./2; 
inday.uptime = 100.*inday.files./61.5;

%%
figure; plot(inday.time(1:end-1),inday.uptime,'o');
%%
datetick('keeplimits')
%%
xl =  [734780.66342 , 734845.5057];
xl = [734780.80645 , 734871.7741]
xlim(xl);


test_span = inday.time>=xl(1) & inday.time<=xl(2);
sum(inday.uptime(test_span))./sum(test_span)

title({['ASSIST uptime at Gan, October 2011 to Jan 2012'];['Span of days: ', ...
    num2str(sum(test_span)), ' Cumulative uptime: ',sprintf('%2.0f', sum(inday.uptime(test_span))./sum(test_span)), '%']})


