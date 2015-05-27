function def_table = output_SPP_table(d);

if ~exist('d','var')
   d = rd_pcasp_dat;
end
[tmp,fstem] = fileparts(d.fname);
if ~exist([d.pname,'tables'],'dir')
   mkdir([d.pname,'tables']);
end

ch30 = def_30;
temp.lines = find(ch30==10);
def_table.line1 = ch30(1:temp.lines(1)-1);
def_table.line2 = ch30(temp.lines(1)+1:temp.lines(2)-1);
def_table.line3 = ch30(temp.lines(2)+1:temp.lines(3)-1);
def_table.line4 = ch30(temp.lines(3)+1:temp.lines(4)-1);
def_table.line5 = ch30(temp.lines(4)+1:temp.lines(5)-1);
def_table.line6 = ch30(temp.lines(5)+1:temp.lines(6)-1);
C = textscan(ch30(temp.lines(6)+1:end),'%d %d %d %d %d');
def_table.range0 = C{2};
def_table.range1 = C{3};
def_table.range2 = C{4};
def_table.range3 = C{5};

for range = 0:3
   if d.range==range
      def_table.(['range',num2str(range)]) = d.countThreshold;
   elseif range==0
      temp1 = linspace(1,4096,ceil(d.chCount/6)+1);
      temp1(1) = [];
      temp2 = linspace(1,4096,ceil(d.chCount/3)+1)+4096;
      temp2(1) = [];
      temp3 = linspace(1,4096,d.chCount - ceil(d.chCount/6)-ceil(d.chCount/3)+1)+ 2*4096;
      temp3(1) = [];
      def_table.(['range',num2str(range)]) =floor([temp1,temp2,temp3])';
      %Let the last half be for the last range
      % Let the first sixth be for the first range
   else
      def_table.(['range',num2str(range)]) = ceil(linspace(1,4096,d.chCount+1))';
      def_table.(['range',num2str(range)])(1) = [];
   end
end
def_table.line2 = strrep(def_table.line2,'30',num2str(d.chCount));
def_table.line2 = strrep(def_table.line2,'Default Defination','Definition');
line3 = ['Generated from file: ',d.fname];
nspaces = ceil((70 - length(line3))/2); spaces = ones([1,nspaces])*32;
def_table.line3 = [def_table.line3, spaces, 'Generated from file: ',d.fname];
% ceil([(4096/30):(4096/30):4096])
txt_out = [[1:d.chCount]',def_table.range0, def_table.range1, def_table.range2,def_table.range3]';
fout_name = [fstem, ...
   '.range_',num2str(d.range),'.',num2str(d.chCount),'_ch.def'];
fid_out = fopen([d.pname, filesep,'tables',filesep,fout_name],'w+');
fprintf(fid_out,'%s \n',def_table.line1);
fprintf(fid_out,'%s \n',def_table.line2);
fprintf(fid_out,'%s \n',def_table.line3);
fprintf(fid_out,'%s \n',def_table.line4);
fprintf(fid_out,'%s \n',def_table.line5);
fprintf(fid_out,'%s \n',def_table.line6);
fprintf(fid_out, '%10.0d %9.0d %9.0d %9.0d %9.d \n', txt_out);
fclose(fid_out);
status = txt2dos([d.pname, filesep,'tables',filesep,fout_name],'true');
% figure(9); 
% ax(1) = subplot(2,1,1); plot([1:d.chCount],d.countThreshold,'ro');
% set(get(gca,'children'),'markerfacecolor','b');
% xlabel('Channel number'),ylabel('Threshold');
% title(fout_name,'interpreter','none');
% ax(2) = subplot(2,1,2); plot([1:d.chCount],d.binCountWidth,'bo');
% set(get(gca,'children'),'markerfacecolor','r');
% xlabel('Channel number'),ylabel('bin width');
% [tmp,fout_fstem] = fileparts(fout_name);
% print(gcf,[d.pname,filesep,'tables',filesep,fout_fstem,'.png'],'-dpng');

function ch30_def = def_30 
ch30_def = char([59
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    10
    59
    42
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    51
    48
    32
    67
   104
    97
   110
   110
   101
   108
    32
    68
   101
   102
    97
   117
   108
   116
    32
    68
   101
   102
   105
   110
    97
   116
   105
   111
   110
    32
    70
   105
   108
   101
    10
    59
    42
    10
    59
    42
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    32
    82
    97
   110
   103
   101
    48
    32
    32
    32
    32
    82
    97
   110
   103
   101
    49
    32
    32
    32
    32
    82
    97
   110
   103
   101
    50
    32
    32
    32
    32
    82
    97
   110
   103
   101
    51
    10
    59
    42
    32
    67
   104
    97
   110
   110
   101
   108
    32
    84
   104
   114
   101
   115
   104
   111
   108
   100
    32
    84
   104
   114
   101
   115
   104
   111
   108
   100
    32
    84
   104
   114
   101
   115
   104
   111
   108
   100
    32
    84
   104
   114
   101
   115
   104
   111
   108
   100
    10
    59
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    42
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    49
    32
    32
    32
    32
    32
    32
    32
    54
    57
    50
    32
    32
    32
    32
    32
    32
    32
    49
    51
    55
    32
    32
    32
    32
    32
    32
    32
    49
    51
    55
    32
    32
    32
    32
    32
    32
    32
    49
    51
    55
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    50
    32
    32
    32
    32
    32
    32
    49
    49
    52
    54
    32
    32
    32
    32
    32
    32
    32
    50
    55
    51
    32
    32
    32
    32
    32
    32
    32
    50
    55
    51
    32
    32
    32
    32
    32
    32
    32
    50
    55
    51
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    51
    32
    32
    32
    32
    32
    32
    49
    56
    49
    52
    32
    32
    32
    32
    32
    32
    32
    52
    49
    48
    32
    32
    32
    32
    32
    32
    32
    52
    49
    48
    32
    32
    32
    32
    32
    32
    32
    52
    49
    48
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    52
    32
    32
    32
    32
    32
    32
    50
    55
    54
    57
    32
    32
    32
    32
    32
    32
    32
    53
    52
    54
    32
    32
    32
    32
    32
    32
    32
    53
    52
    54
    32
    32
    32
    32
    32
    32
    32
    53
    52
    54
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    53
    32
    32
    32
    32
    32
    32
    52
    48
    57
    54
    32
    32
    32
    32
    32
    32
    32
    54
    56
    51
    32
    32
    32
    32
    32
    32
    32
    54
    56
    51
    32
    32
    32
    32
    32
    32
    32
    54
    56
    51
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    54
    32
    32
    32
    32
    32
    32
    52
    49
    57
    54
    32
    32
    32
    32
    32
    32
    32
    56
    49
    57
    32
    32
    32
    32
    32
    32
    32
    56
    49
    57
    32
    32
    32
    32
    32
    32
    32
    56
    49
    57
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    55
    32
    32
    32
    32
    32
    32
    52
    50
    51
    49
    32
    32
    32
    32
    32
    32
    32
    57
    53
    54
    32
    32
    32
    32
    32
    32
    32
    57
    53
    54
    32
    32
    32
    32
    32
    32
    32
    57
    53
    54
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    56
    32
    32
    32
    32
    32
    32
    52
    50
    56
    50
    32
    32
    32
    32
    32
    32
    49
    48
    57
    50
    32
    32
    32
    32
    32
    32
    49
    48
    57
    50
    32
    32
    32
    32
    32
    32
    49
    48
    57
    50
    10
    32
    32
    32
    32
    32
    32
    32
    32
    32
    57
    32
    32
    32
    32
    32
    32
    52
    51
    52
    56
    32
    32
    32
    32
    32
    32
    49
    50
    50
    57
    32
    32
    32
    32
    32
    32
    49
    50
    50
    57
    32
    32
    32
    32
    32
    32
    49
    50
    50
    57
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    48
    32
    32
    32
    32
    32
    32
    52
    53
    51
    55
    32
    32
    32
    32
    32
    32
    49
    51
    54
    53
    32
    32
    32
    32
    32
    32
    49
    51
    54
    53
    32
    32
    32
    32
    32
    32
    49
    51
    54
    53
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    49
    32
    32
    32
    32
    32
    32
    52
    56
    50
    53
    32
    32
    32
    32
    32
    32
    49
    53
    48
    50
    32
    32
    32
    32
    32
    32
    49
    53
    48
    50
    32
    32
    32
    32
    32
    32
    49
    53
    48
    50
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    50
    32
    32
    32
    32
    32
    32
    53
    50
    53
    49
    32
    32
    32
    32
    32
    32
    49
    54
    51
    56
    32
    32
    32
    32
    32
    32
    49
    54
    51
    56
    32
    32
    32
    32
    32
    32
    49
    54
    51
    56
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    51
    32
    32
    32
    32
    32
    32
    53
    56
    52
    57
    32
    32
    32
    32
    32
    32
    49
    55
    55
    53
    32
    32
    32
    32
    32
    32
    49
    55
    55
    53
    32
    32
    32
    32
    32
    32
    49
    55
    55
    53
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    52
    32
    32
    32
    32
    32
    32
    54
    55
    48
    51
    32
    32
    32
    32
    32
    32
    49
    57
    49
    49
    32
    32
    32
    32
    32
    32
    49
    57
    49
    49
    32
    32
    32
    32
    32
    32
    49
    57
    49
    49
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    53
    32
    32
    32
    32
    32
    32
    56
    49
    57
    50
    32
    32
    32
    32
    32
    32
    50
    48
    52
    56
    32
    32
    32
    32
    32
    32
    50
    48
    52
    56
    32
    32
    32
    32
    32
    32
    50
    48
    52
    56
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    54
    32
    32
    32
    32
    32
    32
    56
    51
    51
    53
    32
    32
    32
    32
    32
    32
    50
    49
    56
    53
    32
    32
    32
    32
    32
    32
    50
    49
    56
    53
    32
    32
    32
    32
    32
    32
    50
    49
    56
    53
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    55
    32
    32
    32
    32
    32
    32
    56
    52
    50
    53
    32
    32
    32
    32
    32
    32
    50
    51
    50
    49
    32
    32
    32
    32
    32
    32
    50
    51
    50
    49
    32
    32
    32
    32
    32
    32
    50
    51
    50
    49
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    56
    32
    32
    32
    32
    32
    32
    56
    53
    50
    48
    32
    32
    32
    32
    32
    32
    50
    52
    53
    56
    32
    32
    32
    32
    32
    32
    50
    52
    53
    56
    32
    32
    32
    32
    32
    32
    50
    52
    53
    56
    10
    32
    32
    32
    32
    32
    32
    32
    32
    49
    57
    32
    32
    32
    32
    32
    32
    56
    55
    54
    56
    32
    32
    32
    32
    32
    32
    50
    53
    57
    52
    32
    32
    32
    32
    32
    32
    50
    53
    57
    52
    32
    32
    32
    32
    32
    32
    50
    53
    57
    52
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    48
    32
    32
    32
    32
    32
    32
    56
    57
    56
    49
    32
    32
    32
    32
    32
    32
    50
    55
    51
    49
    32
    32
    32
    32
    32
    32
    50
    51
    49
    54
    32
    32
    32
    32
    32
    32
    50
    51
    49
    54
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    49
    32
    32
    32
    32
    32
    32
    57
    49
    57
    52
    32
    32
    32
    32
    32
    32
    50
    56
    54
    55
    32
    32
    32
    32
    32
    32
    50
    56
    54
    55
    32
    32
    32
    32
    32
    32
    50
    56
    54
    55
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    50
    32
    32
    32
    32
    32
    32
    57
    52
    49
    50
    32
    32
    32
    32
    32
    32
    51
    48
    48
    52
    32
    32
    32
    32
    32
    32
    51
    48
    48
    52
    32
    32
    32
    32
    32
    32
    51
    48
    48
    52
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    51
    32
    32
    32
    32
    32
    32
    57
    53
    55
    50
    32
    32
    32
    32
    32
    32
    51
    49
    52
    48
    32
    32
    32
    32
    32
    32
    51
    49
    52
    48
    32
    32
    32
    32
    32
    32
    51
    49
    52
    48
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    52
    32
    32
    32
    32
    32
    32
    57
    56
    50
    53
    32
    32
    32
    32
    32
    32
    51
    50
    55
    55
    32
    32
    32
    32
    32
    32
    51
    50
    55
    55
    32
    32
    32
    32
    32
    32
    51
    50
    55
    55
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    53
    32
    32
    32
    32
    32
    49
    48
    48
    56
    48
    32
    32
    32
    32
    32
    32
    51
    52
    49
    51
    32
    32
    32
    32
    32
    32
    51
    52
    49
    51
    32
    32
    32
    32
    32
    32
    51
    52
    49
    51
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    54
    32
    32
    32
    32
    32
    49
    48
    52
    54
    48
    32
    32
    32
    32
    32
    32
    51
    53
    53
    48
    32
    32
    32
    32
    32
    32
    51
    53
    53
    48
    32
    32
    32
    32
    32
    32
    51
    53
    53
    48
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    55
    32
    32
    32
    32
    32
    49
    48
    56
    55
    50
    32
    32
    32
    32
    32
    32
    51
    54
    56
    54
    32
    32
    32
    32
    32
    32
    51
    54
    56
    54
    32
    32
    32
    32
    32
    32
    51
    54
    56
    54
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    56
    32
    32
    32
    32
    32
    49
    49
    51
    50
    50
    32
    32
    32
    32
    32
    32
    51
    56
    50
    51
    32
    32
    32
    32
    32
    32
    51
    56
    50
    51
    32
    32
    32
    32
    32
    32
    51
    56
    50
    51
    10
    32
    32
    32
    32
    32
    32
    32
    32
    50
    57
    32
    32
    32
    32
    32
    49
    49
    55
    53
    57
    32
    32
    32
    32
    32
    32
    51
    57
    53
    57
    32
    32
    32
    32
    32
    32
    51
    57
    53
    57
    32
    32
    32
    32
    32
    32
    51
    57
    53
    57
    10
    32
    32
    32
    32
    32
    32
    32
    32
    51
    48
    32
    32
    32
    32
    32
    49
    50
    50
    56
    56
    32
    32
    32
    32
    32
    32
    52
    48
    57
    54
    32
    32
    32
    32
    32
    32
    52
    48
    57
    54
    32
    32
    32
    32
    32
    32
    52
    48
    57
    54
    10])';


















