function pdl = read_pdl(filename)
% pdl = read_pdl(filename)
% This version presizes each of the variables for rec=3600 and then steps
% through the file, saving in 3600 record blocks
%%
max_rec = 3600;
if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('*.dat','pdl');
   pdl.fname = fname;
else
   fid = fopen(filename);
   [pname,fname,ext] = fileparts(filename);
   pdl.fname = [fname ext];
end

chl_choice = sscanf(fgetl(fid),'%s');
pvb = sscanf(fgetl(fid),'%s');

[A]= fscanf(fid,'%f',10);
pdl.vis_ratio = A(1);
pdl.ir_ratio = A(2);
pdl.vis_phi = A(3);
pdl.ir_phi = A(4);
pdl.baselev = A(5);
pdl.time_int = A(6);
pdl.height_int = A(7);
pdl.height_bot = A(8);
pdl.height_top = A(9);
points = A(10);

pdl.range = [pdl.height_bot:pdl.height_int:pdl.height_top]';
while length(pdl.range)>points
pdl.range(1) = [];
if length(pdl.range)>points
 pdl.range(end) = [];
end
end

while ~feof(fid)
   goods = zeros([points,max_rec,]);
   pdl.time = zeros([1,max_rec]);
   pdl.el = zeros([1,max_rec]);
   pdl.az = zeros([1,max_rec]);
   if strcmp(chl_choice,'v')||strcmp(chl_choice,'b')
      if strcmp(pvb,'p')||strcmp(pvb,'b')
         pdl.vis_p = zeros([points,max_rec,]);
      end
      if strcmp(pvb,'v')||strcmp(pvb,'b')
         pdl.vis_v = zeros([points,max_rec,]);
      end
   end
   if strcmp(chl_choice,'i')||strcmp(chl_choice,'b')
      if strcmp(pvb,'p')||strcmp(pvb,'b')
         pdl.ir_p = zeros([points,max_rec,]);
      end
      if strcmp(pvb,'v')||strcmp(pvb,'b')
         pdl.ir_v = zeros([points,max_rec]);
      end
   end
%    if isfield(pdl,'vis_v')&&isfield(pdl,'vis_p')
%       pdl.vis_dpr = zeros([points,max_rec]);
%    end
%    if isfield(pdl,'ir_v')&&isfield(pdl,'ir_p')
%       pdl.ir_dpr = zeros([points,max_rec]);
%    end
   rec = 0;
   while (rec<=max_rec)&&~feof(fid)
      [B,count] = fscanf(fid, '%f',8);
      if count==8
         rec = rec+1;
         pdl.time(rec) = datenum(B(1:6)');
         pdl.el(rec) = B(7);
         pdl.az(rec) = B(8);
         if strcmp(chl_choice,'v')||strcmp(chl_choice,'b')
            if strcmp(pvb,'p')||strcmp(pvb,'b')
               pdl.vis_p(:,rec) = fscanf(fid,'%d',points);
            end
            if strcmp(pvb,'v')||strcmp(pvb,'b')
               pdl.vis_v(:,rec) = fscanf(fid,'%d',points);
            end
         end
         if strcmp(chl_choice,'i')||strcmp(chl_choice,'b')
            if strcmp(pvb,'p')||strcmp(pvb,'b')
               pdl.ir_p(:,rec) = fscanf(fid,'%d',points);
            end
            if strcmp(pvb,'v')||strcmp(pvb,'b')
               pdl.ir_v(:,rec) = fscanf(fid,'%d',points);
            end
         end
      end
   end

   %Now compute the dpr and save the part we've read
%    if isfield(pdl,'vis_v')&&isfield(pdl,'vis_p')
%       pdl.vis_dpr = zeros(size(pdl.vis_v));
%       goods = pdl.vis_p>0;
%       pdl.vis_dpr(goods) = (pdl.vis_ratio.*pdl.vis_v(goods))./pdl.vis_p(goods) - pdl.vis_phi;
%    end
%    if isfield(pdl,'ir_v')&&isfield(pdl,'ir_p')
%       pdl.ir_dpr = zeros(size(pdl.ir_v));
%       goods = pdl.ir_p>0;
%       pdl.ir_dpr(goods) = (pdl.ir_ratio.*pdl.ir_v(goods))./pdl.ir_p(goods) - pdl.ir_phi;
%    end
   if ~isempty([rec:max_rec])
      %trim the unused part
      pdl.time([(rec+1):end]) = [];
      pdl.el([(rec+1):end]) = [];
      pdl.az([(rec+1):end]) = [];
      if strcmp(chl_choice,'v')||strcmp(chl_choice,'b')
         if strcmp(pvb,'p')||strcmp(pvb,'b')
            pdl.vis_p(:,[(rec+1):end]) = [];
         end
         if strcmp(pvb,'v')||strcmp(pvb,'b')
            pdl.vis_v(:,[(rec+1):end]) = [];
         end
      end
      if strcmp(chl_choice,'i')||strcmp(chl_choice,'b')
         if strcmp(pvb,'p')||strcmp(pvb,'b')
            pdl.ir_p(:,[(rec+1):end]) = [];
         end
         if strcmp(pvb,'v')||strcmp(pvb,'b')
            pdl.ir_v(:,[(rec+1):end]) = [];
         end
      end
%       if isfield(pdl,'vis_v')&&isfield(pdl,'vis_p')
%          pdl.vis_dpr(:,[(rec+1):end]) = [];
%       end
%       if isfield(pdl,'ir_v')&&isfield(pdl,'ir_p')
%          pdl.ir_dpr(:,[(rec+1):end]) = [];
%       end
   end
   stem = ['pdl.',datestr(pdl.time(1),'yyyymmdd_HHMMSS')];

   outname = fullfile(pname,[stem,'.mat']);
   disp(['Saving ',outname]);
   save(outname,'pdl','-mat');
end
fclose(fid);

