function  twst_io = TWST_fov(in_file)

if ~isavar('in_file')||~isafile(in_file)
   twst_io =twst4_to_struct;
else
    twst_io =twst4_to_struct(in_file);
end

figure; plot((twst_io.time), twst_io.sig_A(500,:),'o-'); dynamicDateTicks;
figure; plot((twst_io.time), (24*60*60)*diff2(twst_io.time),'o-'); dynamicDateTicks; 
dk = diff2(twst_io.time)>(3./(24*60*60));
chA = zeros([2048,sum(dk)]); 
chB = zeros([128,sum(dk)]);
N=0;di = 1;Nang = 1;
for ij = 1:length(twst_io.time)
 if ~dk(ij)
      
      chA(:,di) = chA(:,di)+twst_io.sig_A(:,ij);
      chB(:,di) = chB(:,di)+twst_io.sig_B(:,ij);
      N = N+1;
 else
      chA(:,di) = chA(:,di)./N;
      chB(:,di) = chB(:,di)./N;
      N= 1;
      di = sum(isnan(sum(chA)))+1;
 end 
 
end
for ang = 1:size(chA,2)
   chA(:,ang) = smooth(chA(:,ang),100,'moving');
   chB(:,ang) = smooth(chB(:,ang),5,'moving');
end

nchA = chA - (min(chA')')*ones([1,86]);
nchB = chB - (min(chB')')*ones([1,86]);
nchA = nchA ./ ((max(nchA')')*ones([1,86]));
nchB = nchB ./ ((max(nchB')')*ones([1,86]));

figure; these = plot([1:86]./20,nchB(10:10:100,:),'-'); recolor(these,twst_io.wl_B(10:10:100));
xlabel('degrees'); ylabel('normalized signal'); title('FOV TWST-10 chB'); colorbar
figure; these = plot([1:86]./20,nchA(200:50:1700,:),'-'); recolor(these,twst_io.wl_A(200:50:1700));
xlabel('degrees'); ylabel('normalized signal'); title('FOV TWST-10 chA'); colorbar

end