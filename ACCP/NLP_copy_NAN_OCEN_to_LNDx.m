function NLP_copy_NAN_OCEN_to_LNDx
% Copy NAN_OCEN files to NAN_LNDD and NAN_LNDV
 OND = setnamedpath('lastpath.mat','NLP_*NAN_OCEN*.csv','Select location of OND files to copy to NAN...');
 
 direc = dir([OND, 'NLP_*_NAN_OCEN_*.csv']);
 for d = length(direc):-1:1
     OCEN = [direc(d).folder, filesep,direc(d).name];
     LNDD = [direc(d).folder, filesep,strrep(direc(d).name,'OCEN','LNDD')];
     LNDV = [direc(d).folder, filesep,strrep(direc(d).name,'OCEN','LNDV')];
     if ~isafile(LNDD)
         copyfile(OCEN,LNDD);
     end
     if ~isafile(LNDV)
         copyfile(OCEN,LNDV);
     end
 end
 
end
     