function status = scanner_inita;
%status = init_scanner
% Opens COM1 with 9600 baud to connect to IDC SmartStep 
% Sends a long initialization string, homes motor, and moves to
% zenith.  Waits for a 'done' response.  Returns a -1 if timed out,
% else returns status as the time of completion.
time_limit = 180;
s1 = serial('COM1','BaudRate', 9600);
fopen(s1);

initstr = ['K 01LA MT:10 MR:10 AU:0 VU:0 DU:9  GR:1:61 OP:IIIIIIII '];
initstr = [initstr, 'ID:UUUUUUUU OD:PPPPPPPP OE:P,00000000  OE:F,XXXXXXXX '];
initstr = [initstr, 'OE:S,XXXXXXXX ET:1 JA:0.1  JL:0.5 JH:2  JE:1 '];
initstr = [initstr, 'HE:0 HF:1 HS:1 HO:0.75 PU:0 SN:0111111 DY:100 '];
initstr = [initstr, 'EM:0 ER:2000 FE:750 IR:25 IT:0 HM:0 PG:10 PV:1 '];
initstr = [initstr, 'BK:0 DF:1,0,4,5  SR:10 MD:1 MV:50.00 AM:10 AH:0 '];
initstr = [initstr, 'AW:0 FA:0 FV:0 KI:0 KP:0 KV:0 EL:0 FL:1 BV:5 '];
initstr = [initstr, 'CU:0 AR:22 MH:H MI:2.8 WA:0 RE:0 IL:0 WC:6 '];
initstr = [initstr, 'WG:20 WM:6 WP:0 PR:1 GH-5 DA0 GO EP 01EX '];

gohome = [' K AC5 DE5 GH-3 GI "done" SP0.75 '];
done = false;
tic;
while ~done
  count = fprintf(s1,[initstr, gohome]);
  done = (findstr(fscanf(s1), 'done')|(toc>time_limit));
end
if toc>time_limit
   status = -1;
else
   status = now;
end
fclose(s1);
return
