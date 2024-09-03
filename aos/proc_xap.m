function [xap] = proc_xap(xap)
if ~isavar('xap')
   xap = rd_xap3;
elseif ~isstruct(xap)
   xap = rd_xap3(xap);
end
if ~isfield(xap,'xap_name');
emanp = fliplr(xap.pname{1});
xap_name = fliplr(strtok(emanp,filesep));
xap.xap_name = xap_name;
end
LPM = round(median(xap.flow_lpm));
P_LPM = get_flowcal(xap_name, LPM);
xap.flow_LPM = polyval(P_LPM, xap.flow_lpm);
xap = xap_cast(xap);
filt = unique(xap.filter_id_hex); 
filt = filt(end);
white_file = [xap.pname{1},'white.',num2str(filt),'.mat'];
if isafile(white_file)
   white = load(white_file);
else
   white.blue = xap.signal_blue(1,:);
   white.green = xap.signal_green(1,:);
   white.red = xap.signal_red(1,:);
end
% Processes TAP after compacting to "tight" me struct
xap.Tr_blu = xap.signal_blue./white.blue;
xap.Tr_grn = xap.signal_green./white.green;
xap.Tr_red = xap.signal_red./white.red;


% These raw Tr values will be re-pinned accordingly at times corresponding to spot-advances.
% xap.Tr_blu = NaN(size(xap.Tr_blu)); xap.Tr_grn = xap.Tr_blu; xap.Tr_red = xap.Tr_blu;
xap.Tr_blu(:,1:2:7) = xap.Tr_blu(:,1:2:7)./xap.Tr_blu(:,9);
xap.Tr_blu(:,9) = xap.Tr_blu(:,9)./xap.Tr_blu(:,10);
xap.Tr_blu(:,2:2:8) = xap.Tr_blu(:,2:2:8)./xap.Tr_blu(:,10);
xap.Tr_blu(:,10) = xap.Tr_blu(:,10)./xap.Tr_blu(:,9);
xap.Tr_grn(:,1:2:7) = xap.Tr_grn(:,1:2:7)./xap.Tr_grn(:,9);
xap.Tr_grn(:,9) = xap.Tr_grn(:,9)./xap.Tr_grn(:,10);
xap.Tr_grn(:,2:2:8) = xap.Tr_grn(:,2:2:8)./xap.Tr_grn(:,10);
xap.Tr_grn(:,10) = xap.Tr_grn(:,10)./xap.Tr_grn(:,9);
xap.Tr_red(:,1:2:7) = xap.Tr_red(:,1:2:7)./xap.Tr_red(:,9);
xap.Tr_red(:,9) = xap.Tr_red(:,9)./xap.Tr_red(:,10);
xap.Tr_red(:,2:2:8) = xap.Tr_red(:,2:2:8)./xap.Tr_red(:,10);
xap.Tr_red(:,10) = xap.Tr_red(:,10)./xap.Tr_red(:,9);

actives = unique(xap.spot); actives = actives(actives>0);
xap.Tr = ones(length(xap.time),3);
for a = 1:length(actives)
   i = find(xap.spot==actives(a),1,'first');
   xap.Tr_red(i:end,actives(a)) = xap.Tr_red(i:end,actives(a))./xap.Tr_red(i,actives(a));
   xap.Tr_grn(i:end,actives(a)) = xap.Tr_grn(i:end,actives(a))./xap.Tr_grn(i,actives(a));
   xap.Tr_blu(i:end,actives(a)) = xap.Tr_blu(i:end,actives(a))./xap.Tr_blu(i,actives(a));
   xap.Tr(i:end,3) = xap.Tr_red(i:end,actives(a));
   xap.Tr(i:end,2) = xap.Tr_grn(i:end,actives(a));
   xap.Tr(i:end,1) = xap.Tr_blu(i:end,actives(a));
   xap.flow_LPM_sm(xap.spot==actives(a)) = smooth(xap.flow_LPM(xap.spot==actives(a)),120);
end
xap.ATN = -100.*log(xap.Tr);
xap.Bap = Bap_ss(xap.time, xap.flow_LPM_sm, xap.Tr, 300);
figure; plot(xap.time, xap.Bap,'-'); dynamicDateTicks; sgtitle(xap.xap_name)

% xap.Bap = Bap_ss(ae33.time, ae33.Flow1.*(1-ae33.zeta_leak), ae33.Tr1, 60, ae33.spot_area);

% me_trim = me;
% flds = fieldnames(me_trim); remv = {};
% for fld = length(flds):-1:1
%    field = flds{fld};
%    if ~all(size(me_trim.(field))==size(me_trim.time))
%       remv = [remv,{field}];
%    end
% end
% me_trim = rmfield(me_trim,remv);

function P_LPM = get_flowcal(xap_name, LPM);
flowcal_path = getfilepath('AMICE_flowcals');
if strcmpi(xap_name, 'tap12')
   if LPM==1
      flowcal = load([flowcal_path,'tap12_1LPM.mat']);
   elseif LPM==2
      flowcal = load([flowcal_path,'tap12_2LPM.mat']);
   end
elseif strcmpi(xap_name, 'tap13')
   flowcal = load([flowcal_path,'tap13_1LPM.mat']);
elseif strcmpi(xap_name, 'clap10')
   flowcal = load([flowcal_path,'clap10.mat']);
elseif strcmpi(xap_name, 'clap92')
   flowcal = load([flowcal_path,'clap92.mat']);
end
P_LPM = flowcal.P_LPM;
return


return


