function ipa = load_all_ipa_aot;

pname = ['C:\case_studies\ipa\barnard\'];
disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.txt');
close('all');
for i = 1:length(dirlist);

    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
if exist('ipa', 'var')
    tmp = load_ipa_aot([pname, dirlist(i).name]);
    good = find((tmp.aot500 >0)&(tmp.cos_sza>0.2)&(tmp.angstrom<-.2));
    w = zeros(size(tmp.time));
    [good_w,rat, mad, yt] = congmad_filter(tmp.time(good), tmp.aot500(good), 15);
    w(good) = good_w;
    if length(find(w>.9))>1
        aot_fig = figure;
        good2 = find(w>.9);
        [aero, eps] = alex_screen(tmp.time(good2),tmp.aot500(good2));
        subplot(3,1,1);
        plot(serial2Hh(tmp.time(good)), [tmp.aot500(good)], 'ko', serial2Hh(tmp.time(w>.9)), [tmp.aot500(w>.9)], 'r.');

        if length(find(eps<1e-3))>1
            hold;
            plot(serial2Hh(tmp.time(good2(eps<1e-3))), [tmp.aot500(good2(eps<1e-3))], 'g.');
        end
        title(datestr(tmp.time(1),'YYYY-mm-DD'))
        ylabel('aot'); axis([5,19,0,1]);
        subplot(3,1,2);
        plot(serial2Hh(tmp.time(good)), [tmp.angstrom(good)], 'ko', serial2Hh(tmp.time(w>.9)), [tmp.angstrom(w>.9)], 'r.')
        if length(find(eps<1e-3))>1
            hold;
            plot(serial2Hh(tmp.time(good2(eps<1e-3))), [tmp.angstrom(good2(eps<1e-3))], 'b.');
        end;
        %    plot(serial2Hh(tmp.time(good)), [tmp.angstrom(good)], 'k.');
        ylabel('angstrom exponent'); axis([5,19,-2,1]);
        subplot(3,1,3);

        plot(serial2Hh(tmp.time(good)), [tmp.colH2O(good)], 'ko', serial2Hh(tmp.time(w>.9)), [tmp.colH2O(w>.9)], 'r.');
        if length(find(eps<1e-3))>1
            hold;
            plot(serial2Hh(tmp.time(good2(eps<1e-3))), [tmp.colH2O(good2(eps<1e-3))], 'c.');
        end
        %    subplot(3,1,3); plot(serial2Hh(tmp.time(good)), [tmp.colH2O(good)], 'b.');
        ylabel('H_2O vapor (cm)'); axis([5,19,-0,4]);
        ipa = cat_ipa(ipa, tmp);
        %ipa = cat_struct_1D(ipa,tmp);
        clear tmp
        pause
        close(aot_fig)
    end
else
    ipa = load_ipa_aot([pname, dirlist(i).name]);
end

end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')

end

function ipa = cat_ipa(ipa, tmp);

ipa.time = [ipa.time; tmp.time];
ipa.cos_sza = [ipa.cos_sza; tmp.cos_sza];
ipa.aot415 = [ipa.aot415; tmp.aot415];
ipa.aot500 = [ipa.aot500; tmp.aot500];
ipa.aot615 = [ipa.aot615; tmp.aot615];
ipa.aot673 = [ipa.aot673; tmp.aot673];
ipa.aot870 = [ipa.aot870; tmp.aot870];
ipa.aot940 = [ipa.aot940; tmp.aot940];
ipa.angstrom = [ipa.angstrom; tmp.angstrom];
ipa.colH2O = [ipa.colH2O; tmp.colH2O];

end

% function struct_1 = cat_struct(struct_1, struct_2, shortest);
% struct_1 = cat_struct(struct_1, struct_2, cat_dim);
% Appending struct_2 to the end of struct_1 along the longest dimension
% common to both structures unless "shortest" is assigned true (1)
% 
% fields_1 = fieldnames(struct_1);
% fields_2 = fieldnames(struct_2);
% rec_length_1 = size(struct_1(fields_1(1)));
% rec_length_2 = size(struct_2(fields_2(1)));
% same = (length(fields_1)==length(fields_2));
% if same
%     for i=1:length(fields_1)
%         same = same * strcmp(fields_1(i),fields_2(i));
%         size_1 = size(struct_1.(char(fields_1(i))));
%         rec_length_1 = intersect(rec_length_1, size_1);
%         size_2 = size(struct_2.(char(fields_2(i))));
%         rec_length_2 = intersect(rec_length_2, size_2);
%     end
% end
% 
% if shortest
%     
% rec_length_1 = max(rec_length_1);
% rec_length_2 = max(rec_length_2);
% 
% max_rec = max(rec_length_1, rec_length_2);
% field = fields_1;
% clear fields_1 fields_2
% At this point we've determined that the two structures have the same
% number of fields, the same fieldnames, and that each structure contains a
% dimension common to all fields. 
% Now append 2 to 1, checking for appropriate dimensionality along the way.
% 
% if same & ~isempty(rec_length_1)& ~isempty(rec_length_2)
%     for i=1:length(field)
%          rdim1 = find(size(struct_1.(char(field(1))))==rec_length_1);
%          rdim2 = find(size(struct_2.(char(field(1))))==rec_length_2);
%          rdim = intersect(rdim1,rdim2);
%          
%              
%          if length(rdim)>1 & exist('cat_dim','var')
%              rdim = intersect(rdim,cat_dim);
%          elseif length(rdim)>1 & ~exist('cat_dim','var')
%              rdim = 
%          if rdim==2
%              struct_1.(char(field(i))) = [struct_1.(char(field(i)))', struct_2.(char(field(i)))']';
%          elseif rdim==1
%              struct_1.(char(field(i))) = [struct_1.(char(field(i))); struct_2.(char(field(i)))];
%          else 
%              disp('Bad cat_dim specified');
% 
%     end
% end    
% 
% end