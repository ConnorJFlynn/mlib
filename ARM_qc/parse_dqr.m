function dq = parse_dqr(ds, var);
% dqr = parse_dqr(ds, var);
% ds = 'sgplssondeC1.c1';
% var = 'rh';
% Hi GK
url = ['http://www.archive.arm.gov/dqrws/ARMDQR?datastream=',ds,'&varname=',var,'&dqrfields=dqrid,starttime,endtime,subject,metric'];
% read contents from url into a string
response = urlread(url);
if ~isempty(response)
response = textscan(response,'%s','delimiter','\r\n');response = response{:};
for r = length(response):-1:1
  A = textscan(response{r}, '%s %d %d %s %s','delimiter','|'); 
  dq_id = A{1}; dq_id = dq_id{:}; % 
  dq.id_str(r) = {dq_id};
  dq.id(r) = sscanf(strrep(dq_id,'D',''),'%f');
  dq.start_time(r) = epoch2serial(double(A{2}));
  dq.end_time(r) = epoch2serial(double(A{3}));
  dq.quality_str(r) = [A{5}];
  if strcmp(A{5},'missing')
     dq.qs(r) = 3;
  elseif strcmp(A{5},'incorrect')
     dq.qs(r) = 2;
  elseif strcmp(A{5},'suspect')
     dq.qs(r) = 1;
  elseif strcmp(A{5},'transparent')
     dq.qs(r) = 0;
  end
  dq.desc(r) = [A{4}];     
end
else
   dq = [];
end
% dqr.(strrep(ds,'.','_')).(var) = dq;


return