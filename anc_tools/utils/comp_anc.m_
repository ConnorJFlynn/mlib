if ~exist('anc1','var')
   anc1 = ancload;
end
if ~exist('anc2','var')
   anc2 = ancload;
end
fields1 = fieldnames(anc1.vars);
fields2 = fieldnames(anc2.vars);
%%
next=1;
for f1 = 1:length(fields1)
%    if (next==1)&&strcmp(anc1.recdim.name,char(anc1.vars.(fields1{f1}).dims))&&~strcmp(fields1{f1}(1:3),'qc_')
   if (next==1)&&strcmp(anc1.recdim.name,char(anc1.vars.(fields1{f1}).dims))
      for f2 = 1:length(fields2)
         if (next==1)&&(strcmp(anc2.recdim.name,char(anc2.vars.(fields2{f2}).dims))&&(strcmp(fields1{f1},fields2{f2})))
            [oneintwo,twoinone] = nearest(anc1.time, anc2.time);
            not_same = find(anc1.vars.(fields1{f1}).data(oneintwo)~=anc2.vars.(fields2{f2}).data(twoinone));
            if length(not_same)>1
               xl = [serial2Hh(anc1.time(oneintwo(not_same(1)))),serial2Hh(anc1.time(oneintwo(not_same(end))))];

               ax(1) = subplot(2,1,1);
               plot(serial2Hh(anc1.time),anc1.vars.(fields1{f1}).data,'g.',...
                  serial2Hh(anc2.time),anc2.vars.(fields2{f2}).data,'r.');
               xlim(xl);
%                ylim([0,1.2*max([1,anc1.vars.(fields1{f1}).data(~isNaN(anc1.vars.(fields1{f1}).data))])]);
               title({anc1.fname,fields1{f1}},'interpreter','none');
               ylabel(anc1.vars.(fields1{f1}).atts.units.data);
               ax(2)= subplot(2,1,2);
               plot(serial2Hh(anc1.time(oneintwo)),anc1.vars.(fields1{f1}).data(oneintwo)-anc2.vars.(fields2{f2}).data(twoinone),'b.')
               ylabel(anc1.vars.(fields1{f1}).atts.units.data);
               %             ylim([0,1.2*max([1 anc1.vars.(fields1{f1}).data(oneintwo)-anc2.vars.(fields2{f2}).data(twoinone)])]);
               title('orig - new');
               xlabel('time (Hh)')
               xlim(xl);
               linkaxes(ax,'x')
               zoom('on')
               next = menu('next','next','done');
            elseif length(not_same)==1
               fields1{f1}
               disp(['index number, time(Hh), file 1, file 2'])
               [not_same, serial2Hh(anc1.time(oneintwo(not_same))),anc1.vars.(fields1{f1}).data(oneintwo(not_same)),anc2.vars.(fields2{f2}).data(twoinone(not_same)) ]
            else
               disp(['Matching values for ',fields1{f1}])
         end
      end
   end
end
close('all')
