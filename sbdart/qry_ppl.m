function qry = qry_ppl(qry)

if ~isstruct(qry)||isempty(qry)
   error('Must include non-empty qry struct');
else
 field = fieldnames(qry);
 for f = 1:length(field)
    if ~strcmp(upper(field{f}),field{f})
       qry.(upper(field{f})) = qry.(field{f});
       qry = rmfield(qry,field{f});
    end
 end
 if ~isfield(qry,'IOUT')
    qry.iout=21;
 end
% checks whether required elements are defined for PPL scan and defines them if not
if ~isfield(qry,'sza')&&~isfield(qry,'SZA')
   error('Must include SZA for PPL scan')
end
if ~isfield(qry,'WLBAER')&&~isfield(qry,'wlbaer')
   error('Must include WLBAER for PPL scan')
end
if ~isfield(qry,'QBAER')&&~isfield(qry,'qbaer')
   error('Must include QBAER for PPL scan')
end
if ~isfield(qry,'WBAER')&&~isfield(qry,'wbaer')
   error('Must include WBAER (ssa) for PPL scan')
end
if ~isfield(qry,'GBAER')&&~isfield(qry,'gbaer')
   error('Must include GBAER (asymmetry parameter) for PPL scan')
end

if ~isfield(qry,'nf')&&~isfield(qry,'NF') % Modtran is 3
   qry.NF=3;
end
if ~isfield(qry,'idatm')&&~isfield(qry,'IDATM')
   qry.IDATM=2; % 2 MID-LATITUDE SUMMER, 3 Mid-lat winter
end
% if ~isfield(qry,'isat')&&~isfield(qry,'ISAT')
%    qry.ISAT=-2;
% end
if ~isfield(qry,'wlinf')&&~isfield(qry,'WLINF')
   qry.WLINF=0.440;
end
if ~isfield(qry,'wlsup')&&~isfield(qry,'WLSUP')
   qry.WLSUP=0.440;
end
if ~isfield(qry,'wlinc')&&~isfield(qry,'WLINC')
   qry.WLINC=.001;
end
if ~isfield(qry,'isalb')&&~isfield(qry,'ISALB') % vegetation
   qry.ISALB=6;
end
if ~isfield(qry,'iaer')&&~isfield(qry,'IAER') % user-specified aerosol model
   qry.IAER=5;
end
if ~isfield(qry,'abaer')&&~isfield(qry,'ABAER')
   P = polyfit(log(qry.WLBAER), log(qry.QBAER),1);
   qry.ABAER = -real(P(1));
end
if ~isfield(qry,'rhaer')&&~isfield(qry,'RHAER')
   qry.RHAER=0.8;
end
if ~isfield(qry,'saza')&&~isfield(qry,'SAZA')
   qry.SAZA=180;
end
if ~isfield(qry,'nstr')&&~isfield(qry,'NSTR')
   qry.NSTR=20;
end
if ~isfield(qry,'uzen')&&~isfield(qry,'UZEN')
   qry.UZEN = [0:5:90];
end
qry.UZEN = fliplr(180-setxor(qry.UZEN,qry.SZA));
qry.PHI=[0,180];
qry.CORINT='.true.';
end

end

