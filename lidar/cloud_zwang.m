function [base, top] = cloud_zwang(height, prof, ref, in_time)
% [bs tp] = cloud_zwang(height, prof, ref, in_time);
%  This routine calls Zhien Wang's cloud detection algorithm written in
%  Fortan and compiled as a mex file MPLbase_sub1.  The height and lidar 
%  profile are required.  If no reference molecular profile is provided it 
%  will be generated from standard atmosphere T and P profiles.  If time 
%  is not provided it is set to -9999.
%  Supplied lidar and molecular reference profiles are scaled by 1e4 and 25 
%  (respectively) this routine before passing to MPLbase_sub1
if ~exist('height','var')
   disp('cloud_zwang requires height and backscatter as input arguments.')
   return
else 
   height = double(height);
end
if ~exist('prof','var')
   disp('cloud_zwang requires height and backscatter as input arguments.')
   return
else 
   prof = 1e4.*double(prof);
end
if length(height)~=length(prof)
   disp('height and backscatter must have same length.')
   return
end
[m,n] =size(height);
[M,N] = size(prof);
if m~=n && m==N && n==M %transpose prof to match height orientation
   disp('Transposing prof to match height orientation.  For improved efficiency do this before calling cloud_zwang.');
   prof = prof';
end
if ~exist('ref','var')
   [ref] = 25.*double(std_ray_atten(height));
   return
else 
   ref = 25.*double(ref);
end
if ~exist('in_time','var')
   in_time = -9999;
end
n_height = length(height);
% [bs, tp] = MPLbase_sub1(in_time,50 , prof(1:50) ,height(1:50) , ref(1:50));
[base, top] = MPLbase_sub1(in_time,n_height , prof ,height , ref);
if log10(base)<-3 || log10(base)>2 || log10(top)<-3 || log10(top)>2
   base = NaN;
   top = NaN;
end
% pause(.001);
return
