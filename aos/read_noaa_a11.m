function aos_out = read_noaa_a11(infile)
% Brute force read of A11a packets from A11 file for PSAP

% A11a,SGP,1434110580,2015-06-12T12:03:00Z,0000,1014,1434031861,0000.88,0000.95,0000.69,0.6119455,0.6524044,0.7023200,73309.269
if ~exist('infile','var')||~exist(infile,'file')
    infile = getfullname('*A11_*','psap_raw','Select NOAA raw psap 60s file');
end

fid = fopen(infile,'r');

this = fgetl(fid);
while strcmp(this(1),'!')&&~feof(fid)
    mark = ftell(fid);
    this = fgetl(fid);    
end

i = 0;j = 0;
while ~feof(fid)
    if ~isempty(strfind(this,'A11a'))
        i = i +1;
    end
    if ~isempty(strfind(this,'A11m'))
        j = j +1;
    end    
    this = fgetl(fid);
end
if ~isempty(strfind(this,'A11a'))
    i = i +1;
end
if ~isempty(strfind(this,'A11m'))
    j = j +1;
end

if i>0 
    % redefine the fields we want
    %
    % A11a,SGP,1434119400,2015-06-12T14:30:00Z,0010,1054,1434031861,-000.33,0000.18,-000.60,0.6052328,0.6461235,0.6965501,81500.303
    a_str = '%*s %*s %f %*s %*s %*s %d %f %f %f %f %f %f %f';
    %A11m,SGP,1434111300,2015-06-12T12:15:00Z,0048782,0090645,0029834,0159555,0190420,0064669,0.0001017,0.0000949,0.0000284,0.0000317,0.0000183,0.0000670,1.049
    m_str = '%*s %*s %f %*s %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f';
    fseek(fid,mark,-1);
    ii = 0;jj = 0;
while ~feof(fid)
    this = fgetl(fid);
    if ~isempty(strfind(this,'A11a'))
        ii = ii +1;
        A = textscan(this,a_str,'delimiter',',');
        aos_out.time(ii) = epoch2serial(A{1})
        aos_out.filter_ID(ii) = A{2};
        aos_out.Ba_B(ii) = A{3};aos_out.Ba_G(ii) = A{4};aos_out.Ba_R(ii) = A{5};
        aos_out.Tr_B(ii) = A{6};aos_out.Tr_G(ii) = A{7};aos_out.Tr_R(ii) = A{8};
        aos_out.L(ii) = A{9};
    end
    if ~isempty(strfind(this,'A11m'))
        jj = jj +1;
        B = textscan(this,m_str,'delimiter',',');
        m.time(jj) = epoch2serial(B{1});
        m.flow(jj) = B{2};
    end
        
    
end    
    
aos_out.flow_rate = interp1(m.time, m.flow, aos_out.time, 'nearest','extrap');    
    
 
else
    aos_out= [];
end

fclose(fid);



return