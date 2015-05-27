function ipa = load_ipa_aot(filename);

if nargin==0
    [fname pname] = uigetfile('*.txt');
    filename = [pname, fname];
end
 slash = max(findstr(filename, '\'));
 pname = filename(1:slash);
 fname = filename(slash+1:end);
 d_str = fname(1:8);

temp_file = load([pname fname]);
ipa.time = datenum(d_str(1:4),'yyyy')-1+temp_file(:,2);
ipa.cos_sza = temp_file(:,3);
ipa.aot415 =temp_file(:,4);
ipa.aot500 =temp_file(:,5);
ipa.aot615 =temp_file(:,6);
ipa.aot673 =temp_file(:,7);
ipa.aot870 =temp_file(:,8);
ipa.aot940 =temp_file(:,9);
ipa.angstrom =temp_file(:,10);
ipa.colH2O =temp_file(:,11);
% figure; plot(serial2doy0(ipa.time), [ipa.aot415 , ipa.aot500,ipa.aot615 , ipa.aot673,ipa.aot870 , ipa.aot940], '.')