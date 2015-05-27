function diff_count = matching_fields(anc1,anc2);
% I want this function to display list of fields and attributes in one file
% not found in the other, and to display the values of matched fields when
% the contents differ.
if ~exist('anc1','var')
   anc1 = ancload;
end
if ~exist('anc2','var')
   anc2 = ancload;
end
%%
save('anc1.mat','anc1');
save('anc2.mat','anc2');

%%
anc1 = load('anc1.mat');anc1 = anc1.anc1;
anc2 = load('anc2.mat');anc2 = anc2.anc2;


%%
diff_count = 0;
%Check dims...
dims1 = fieldnames(anc1.dims);
dims2 = fieldnames(anc2.dims);
for d1 = length(dims1):-1:1
   for d2 = length(dims2):-1:1
      if strcmp(dims1{d1},dims2{d2})
         diff_count = diff_count + compare_dims(anc1.dims.(dims1{d1}),anc2.dims.(dims2{d2}));
         dims1(d1) = [];
         dims2(d2) = [];
         break
      end
   end
end

if ~isempty(dims1)
   disp(['Unmatched dims from anc1 '])
   disp(dims1);
   diff_count = diff_count +1;
end
if ~isempty(dims2)
   disp(['Unmatched dims from anc2 '])
   disp(dim2);
   diff_count = diff_count +1;
end
%%
%Separately check all non-recdim dims.

%%
%Check global atts
diff_count = diff_count + check_atts(anc1.atts,anc2.atts);

fields1 = fieldnames(anc1.vars);
fields2 = fieldnames(anc2.vars);
%%
next=1;
for f1 = 1:length(fields1)
   for f2 = 1:length(fields2)
      if (next<3)&&(strcmp(fields1{f1},fields2{f2}))
         % field names are same
         % Now check atts
         diff_count = diff_count + check_atts(anc1.vars.(fields1{f1}).atts,anc2.vars.(fields2{f2}).atts);
         % Now check dims
         if isempty(anc1.vars.(fields1{f1}).dims{1})&&isempty(anc2.vars.(fields2{f2}).dims{1})
            %both are dimensionless, so check the single values
            if anc1.vars.(fields1{f1}).data ~= anc2.vars.(fields2{f2}).data
               disp(['anc1 ',fields1{f1},' : ',num2str(anc1.vars.(fields1{f1}).data)]);
               disp(['anc2 ',fields2{f2},' : ',num2str(anc2.vars.(fields2{f2}).data)]);
               diff_count = diff_count + 1;
            end
         elseif  xor(isempty(anc1.vars.(fields1{f1}).dims{1}), isempty(anc2.vars.(fields2{f2}).dims{1}))...
               ||xor((max(size(anc1.vars.(fields1{f1}).dims))>1),(max(size(anc2.vars.(fields2{f2}).dims))>1))
            %Only one is dimensionless, certainly not a match.
            disp([fields1{f1},' Dimensionality not the same for this field!']);
            diff_count = diff_count + 1;
         elseif ~any(strcmp(anc1.vars.(fields1{f1}).dims,anc1.recdim.name))&&~any(strcmp(anc2.vars.(fields2{f2}).dims,anc2.recdim.name))
            %static fields
            equal = (anc1.vars.(fields1{f1}).data==anc2.vars.(fields2{f2}).data);
            if sum(~equal)>1
               figure; 
               plot(find(equal),anc1.vars.(fields1{f1}).data(equal),'k.',...
                  find(~equal),anc1.vars.(fields1{f1}).data(~equal),'rx',...
                  find(~equal),anc2.vars.(fields2{f2}).data(~equal),'ro')
            end
         else
            %Both fields are similarly dimensioned versus time.
disp(['Comparing ',char(fields1{f1})]);
            [oneintwo,twoinone] = nearest(anc1.time, anc2.time);
            not_in_both = length(setxor(oneintwo,[1:length(anc1.time)]))+length(setxor(twoinone,[1:length(anc2.time)]));
            not_same = find(anc1.vars.(fields1{f1}).data(oneintwo)~=anc2.vars.(fields2{f2}).data(twoinone));
            if length(anc1.vars.(fields1{f1}).dims)==1
            if (not_in_both==0 && (length(not_same)==1)) %Then just show the difference, don't plot
               disp(fields1{f1})
               disp(['index number, time(Hh), file 1, file 2'])
               disp([not_same, serial2doy(anc1.time(oneintwo(not_same))),anc1.vars.(fields1{f1}).data(oneintwo(not_same)),anc2.vars.(fields2{f2}).data(twoinone(not_same)) ]);

            elseif (not_in_both>0 || (length(not_same)>1)) % Then plot the fields and differences
               if isempty(not_same)
                  xl= [serial2doy(min([anc1.time, anc2.time])),serial2doy(max([anc1.time, anc2.time]))];
               else
               xl = [serial2doy(anc1.time(oneintwo(not_same(1)))),serial2doy(anc1.time(oneintwo(not_same(end))))];
               end
               ax(1) = subplot(2,1,1);
               
               if isfield(anc1.vars.(fields1{f1}).atts,'missing_value')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing_value.data;
               elseif isfield(anc1.vars.(fields1{f1}).atts,'missing_data')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing_data.data;
               elseif isfield(anc1.vars.(fields1{f1}).atts,'missing')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing.data;
               elseif isfield(anc1.atts,'missing_value')
                  missing_val = anc1.atts.missing_value.data;
               elseif isfield(anc1.atts,'missing_data')
                  missing_val = anc1.atts.missing_data.data;
               elseif isfield(anc1.atts,'missing')
                  missing_val = anc1.atts.missing.data;
               else
                  missing_val = -9999;
               end
               not_missing1 = ((anc1.vars.(fields1{f1}).data < (1.001*missing_val))|(anc1.vars.(fields1{f1}).data> (0.999*missing_val)))&(~isNaN(anc1.vars.(fields1{f1}).data));
               not_missing2 = ((anc2.vars.(fields2{f2}).data < (1.001*missing_val))|(anc2.vars.(fields2{f2}).data> (0.999*missing_val)))&(~isNaN(anc2.vars.(fields2{f2}).data));
               yl(1) = 0.9*min(min([anc1.vars.(fields1{f1}).data(not_missing1),anc2.vars.(fields2{f2}).data(not_missing2)]));
               yl(2) = 1.1*max(max([anc1.vars.(fields1{f1}).data(not_missing1),anc2.vars.(fields2{f2}).data(not_missing2)]));
               plot(serial2doy(anc1.time),anc1.vars.(fields1{f1}).data,'g.',...
                  serial2doy(anc2.time),anc2.vars.(fields2{f2}).data,'r.');
               legend('anc1','anc2')
               xlim(xl);ylim(yl);
               %  ylim([0,1.2*max([1,anc1.vars.(fields1{f1}).data(~isNaN(anc1.vars.(fields1{f1}).data))])]);
               title({anc1.fname,fields1{f1}},'interpreter','none');
               ylabel(anc1.vars.(fields1{f1}).atts.units.data);
               ax(2)= subplot(2,1,2);
               plot(serial2doy(anc1.time(oneintwo)),anc1.vars.(fields1{f1}).data(oneintwo)-anc2.vars.(fields2{f2}).data(twoinone),'b.')
               ylabel(anc1.vars.(fields1{f1}).atts.units.data);
               %             ylim([0,1.2*max([1 anc1.vars.(fields1{f1}).data(oneintwo)-anc2.vars.(fields2{f2}).data(twoinone)])]);
               if not_in_both>0
                  unequal = '(Original vectors are not equal length)';
               else
                  unequal = [];
               end

               title({'orig - new',unequal});
               xlabel('time (Hh)')
               xlim(xl);
               linkaxes(ax,'x')
               zoom('on')
               next = menu('next','next','new figure','done');
               if next==2
                  figure;
               end
            else
               disp(['Matching values for ',fields1{f1}])
            end
            else %These are N-dim fields so generate images
               if isfield(anc1.vars.(fields1{f1}).atts,'missing_value')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing_value.data;
               elseif isfield(anc1.vars.(fields1{f1}).atts,'missing_data')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing_data.data;
               elseif isfield(anc1.vars.(fields1{f1}).atts,'missing')
                  missing_val = anc1.vars.(fields1{f1}).atts.missing.data;
               elseif isfield(anc1.atts,'missing_value')
                  missing_val = anc1.atts.missing_value.data;
               elseif isfield(anc1.atts,'missing_data')
                  missing_val = anc1.atts.missing_data.data;
               elseif isfield(anc1.atts,'missing')
                  missing_val = anc1.atts.missing.data;
               else
                  missing_val = -9999;
               end
               mask = ones(size(anc1.vars.(fields1{f1}).data(:,oneintwo)));
               missing1 =(anc1.vars.(fields1{f1}).data(:,oneintwo))<(.9*missing_val);
               missing2 =(anc1.vars.(fields1{f1}).data(:,oneintwo))<(.9*missing_val);
               mask(missing1|missing2) = NaN;
               if all(anc1.vars.(fields1{f1}).data(~missing1&~missing2)==...
                     anc2.vars.(fields2{f2}).data(~missing1&~missing2))
                  disp(['Matching values for ',fields1{f1}])
               else
                  ax(1) = subplot(2,2,1);
                  ylen1 = size(anc1.vars.(fields1{f1}).data,1);
                  imagesc([1:length(oneintwo)], [1:ylen1],mask.*anc1.vars.(fields1{f1}).data(:,oneintwo)); axis('xy');
                  cv = caxis; colorbar;
                  title({'anc1',fields1{f1}},'interp','none')
                  
                  ax(2) = subplot(2,2,2);
                  ylen2 = size(anc2.vars.(fields2{f2}).data,1);
                  
                  imagesc([1:length(twoinone)], [1:ylen2],mask.*anc2.vars.(fields2{f2}).data(:,twoinone)); axis('xy');
                  caxis(cv); colorbar;
                  title({'anc2',fields2{f2}},'interp','none')
                  
                  
                  ax(3) = subplot(2,2,3);
                  imagesc([1:length(oneintwo)], [1:ylen1],mask.*(anc1.vars.(fields1{f1}).data(:,oneintwo)-anc2.vars.(fields2{f2}).data(:,twoinone))); axis('xy');
                  caxis(cv); colorbar;
                  title('anc1 - anc2')
                  
                  ax(4) = subplot(2,2,4);
                  imagesc([1:length(oneintwo)], [1:ylen1],mask.*(abs(anc1.vars.(fields1{f1}).data(:,oneintwo)-anc2.vars.(fields2{f2}).data(:,twoinone))./(anc1.vars.(fields1{f1}).data(:,oneintwo)))); axis('xy');
                  caxis([0,1]); colorbar;
                  title('abs((anc1-anc2)/anc1)')
                  linkaxes(ax,'xy');zoom('on');
                  next = menu('next','next','new figure','done');
                  if next==2
                     figure;
                  end
               end %end of 2D compare failtest
            end % end of 2D loop
            
         end
         break
      end
   end
end
% close('all')

function diff_count = compare_dims(dim1,dim2);
%Check atts...
diff_count = 0;
dim1_names = fieldnames(dim1);
dim2_names = fieldnames(dim2);

for a1 = length(dim1_names):-1:1
   for a2 = length(dim2_names):-1:1
      if strcmp(dim1_names{a1},dim2_names{a2})
         if dim1.(dim1_names{a1}) ~=dim2.(dim2_names{a2})
            disp(['anc1 ',dim1_names{a1}, ' = ', num2str(dim1.(dim1_names{a1}))])
            disp(['anc2 ',dim2_names{a2}, ' = ', num2str(dim2.(dim2_names{a2}))])
            diff_count = diff_count + 1;
         end
         dim1_names(a1) = [];
         dim2_names(a2) = [];
         break
      end
   end
end
if ~isempty(dim1_names)
   disp(['Unmatched elements from dim1: '])
   disp(dim1_names);
   diff_count = diff_count +1;
end
if ~isempty(dim2_names)
   disp(['Unmatched elements from dim2: '])
   disp(dim2_names);
   diff_count = diff_count +1;
end

function diff_count = check_atts(atts1,atts2);
%Check atts...
diff_count = 0;
atts1_names = fieldnames(atts1);
atts2_names = fieldnames(atts2);

for a1 = length(atts1_names):-1:1
   for a2 = length(atts2_names):-1:1
      if strcmp(atts1_names{a1},atts2_names{a2})
         if any(size(atts1.(atts1_names{a1}).data)~=size(atts2.(atts2_names{a2}).data))|(atts1.(atts1_names{a1}).data ~=atts2.(atts2_names{a2}).data)
            disp(['anc1 ',atts1_names{a1}])
            atts1.(atts1_names{a1}).data
            disp(['anc2 ',atts2_names{a2}])
            atts2.(atts2_names{a2}).data
            diff_count = diff_count + 1;
         end
         atts1_names(a1) = [];
         atts2_names(a2) = [];
         break
      end
   end
end
if ~isempty(atts1_names)
   disp(['Unmatched atts from anc1: '])
   disp(atts1_names);
   diff_count = diff_count + 1;
end
if ~isempty(atts2_names)
   disp(['Unmatched atts from anc2: '])
   disp(atts2_names);
   diff_count = diff_count + 1;
end
