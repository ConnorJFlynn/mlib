function [out] = parse_iout6_(w,qry)
rows = find(w==10);
A = textscan(w(rows(3):rows(4)),'%f'); A = A{1};
out.WL =A(1); out.FFV = A(2);
out.BOTDN = A(6); out.BOTDIR = A(8);
out.BOTDIF = out.BOTDN-out.BOTDIR; out.DIRN2DIF = out.BOTDIR./out.BOTDIF;

str = w(rows(4):rows(5));
[nphi, count, errmsg, nextindex] = sscanf(str,'%d',1);
[nuzen, count, errmsg, nextindex] = sscanf(str(nextindex:end),'%d',1);
str = w(rows(5):end);
[phi, count, errmsg, nextindex] = sscanf(str,'%e',nphi);
out.phi = phi;
str = str(nextindex:end);
[uzen, count, errmsg,nextindex] = sscanf(str, '%e', nuzen);

str = str(nextindex:end);
uurs = zeros([nphi, nuzen]);
[temp, count, errmsg,nextindex] = sscanf(str, '%e', nphi*nuzen);
uurs(:) = temp;

out.SZA = qry.SZA;
if isfield(qry,'TBAER')
   out.aod = qry.TBAER;
elseif isfield(qry,'QBAER')
   out.aod = qry.QBAER;
end
if ~isfield(qry,'ABAER')
   if isfield(qry,'QBAER')&&length(qry.QBAER)>1
      qry.ABAER = ang_exp(qry.QBAER(1), qry.QBAER(2),qry.WLBAER(1),qry.WLBAER(2));
   elseif isfield(qry,'TBAER')&&length(qry.TBAER)>1
      qry.ABAER = ang_exp(qry.TBAER(1), qry.TBAER(2),qry.WLBAER(1),qry.WLBAER(2));
   else
      qry.ABAER = 1;
   end
end
if isfield(qry,'QBAER')
   tau = qry.QBAER;
elseif isfield(qry,'TBAER')
   tau = qry.TBAER;
end
out.aod = ang_coef(tau(1), qry.ABAER, qry.WLBAER(1), out.WL);
if length(qry.WLBAER)>1 & length(qry.WBAER)>1
   out.SSA = polyval(polyfit(qry.WLBAER, qry.WBAER, 1),out.WL);
else
   if isfield(qry,'WBAER')
      out.SSA = qry.WBAER;
   else
      out.SSA = .95;
   end
end

if nphi==1 && nuzen==1 
   out.zen = (180-uzen);
   out.SA = qry.SZA - out.zen;
   out.rad = uurs';
   
elseif nphi<=2 && nuzen>1 %assume it is PPL?
   out.zen =(180 - uzen); out.zen = [out.zen;-flipud(out.zen)];
   out.SA = qry.SZA - out.zen;
   out.rad = [uurs(1,:),fliplr(uurs(2,:))]';
   
elseif nuzen==1 && nphi>1 % then alm
   out.zen =(180 - uzen);
   out.SA = scat_ang_degs(out.SZA, 0, ones(size(out.phi))*out.zen, out.phi);
   out.rad = uurs; 
elseif nphi>2&&nuzen>2
   out.zen = (180-uzen)';
   for z = length(out.zen):-1:1
   out.SA(:,z) = scat_ang_degs(out.SZA, 0, ones(size(out.phi))*(out.zen(z)), out.phi);
   end
   out.rad = uurs;
   % figure; plot(out.zen, out.rad(1,:),'-o')
else
end