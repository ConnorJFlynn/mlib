function out_val = get_sbdart_aux_data(time, in_path, in_field);
dstr = datestr(time(1),'yyyymmdd');
infile = dir([in_path,'*',dstr,'*.cdf']);
if isempty(infile)
   infile= dir([in_path,'*',dstr,'*.nc']);
end
if isempty(infile)
   infile = dir([in_path,'*.cdf']);
end
if isempty(infile)
   infile = dir([in_path,'*.nc']);
end
anc = ancload([in_path,infile(1).name]);
for ff = 2:length(infile)
%    disp('I am inside.')
   anc = anccat(anc,ancload([in_path,infile(ff).name]));
end
%%
NaNs = anc.vars.(in_field).data <=0;
out_vals = anc.vars.(in_field).data;
out_vals(NaNs) = interp1(anc.time(~NaNs),anc.vars.(in_field).data(~NaNs),anc.time(NaNs), 'linear','extrap');
in.t = ((anc.time)>=time(1)) & ((anc.time)<=time(end));
if sum(in.t)==0
   %then interpolate
%    out_val = interp1(anc.time, anc.vars.(in_field).data,mean(time),'linear','extrap');
   out_val = interp1(anc.time, out_vals,mean(time),'linear','extrap');
else
   %take mean
%    out_val = mean(anc.vars.(in_field).data(in.t));
   out_val = mean(out_vals(in.t));
end
%%
return

