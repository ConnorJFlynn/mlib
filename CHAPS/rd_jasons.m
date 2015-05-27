function packet = rd_jasons(fname);
% fname = 'data_file_1830to1835.txt';
if ~exist('fname','var')||~exist(fname,'file')
   [fname,pname]= uigetfile('data_file*.txt');
   fname = [pname, filesep,fname];
end
   
fid = fopen(fname);
%%
r = textscan(fid, '%f %*[^\n]');
fseek(fid,0,-1);
tags = find(r{:} == -999999999);
disp(['Reading ',num2str(length(tags)),' packets from ',fname]);
ens = diff([0;tags])-2; %subtract 2, one for param and one for -9999999 tag.
for t = length(ens):-1:1
   C = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]',1,'delimiter','\t');
   packet(t).params = double([C{:}]);
   C = textscan(fid,'%f %f %*[^\n]',ens(length(ens)-t+1),'delimiter','\t');
   packet(t).col = double([C{1},C{2}]);
%    packet(t).col2 = double(C{2});
 tag =  textscan(fid,'%f %*[^\n]',1) ;
end
packet = fliplr(packet);
fclose(fid);