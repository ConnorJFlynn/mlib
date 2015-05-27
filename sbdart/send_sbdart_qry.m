function reply = send_sbdart_qry(qry);

if ~iscell(qry)
fields = fieldnames(qry);
for ff = 1:length(fields)
   qry_cell(2*ff -1) = fields(ff);
   qry_cell(2*ff) = {qry.(fields{ff})};
end
else
   qry_cell = qry;
end

[WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR] = sbdart(qry_cell{:});

[WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR] = ...
sbdart(qry_cell{:});


reply.wlinf = WLINF;
reply.wlsup = WLSUP;
reply.ffew = FFEW;
reply.topdn = TOPDN;
reply.topup = TOPUP;
reply.topdir = TOPDIR;
reply.botdn = BOTDN;
reply.botup = BOTUP;
reply.botdir = BOTDIR;
