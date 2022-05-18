function [that, this] = loadit(incoming);
if ~isavar('incoming')
   [fname, pname] = uigetfile;
else
   if exist(incoming, 'dir')
      [fname, pname] = uigetfile([incoming,'\*.*']);
   elseif exist(incoming, 'file')
      [pname, fname, ext] = fileparts(incoming);
      fname = [fname, ext];
   else
      [pname, fname, ext] = fileparts(incoming);
      [fname, pname] = uigetfile([pname,'\*.*']);
   end
end
if ~isempty(pname)
   this = importdata([pname, '\', fname]);
   if isfield(this, 'colheaders')
      for i = 1:length(this.colheaders)
         fieldname = strtrim(this.colheaders(i));
         fieldname = legalize(fieldname);
         if isempty(regexp(fieldname{1}(1),'[a-zA-Z]'))
            fieldname = {['Col',num2str(i),'_',fieldname{:}]};
         end
         that.(fieldname{:}) = this.data(:,i);
      end
   else
      if isfield(this,'data')
         that = this.data;
         this = this.textdata;
      else
         that = this;
         this = [];
      end
   end
else
   this = [];
   that = [];
end
return %loadit

function fieldname = legalize(fieldname)
fieldname = strrep(fieldname, ' ', '_space_');
fieldname = strrep(fieldname, '~', '_tilde_');
fieldname = strrep(fieldname, '!', '_bang_');
fieldname = strrep(fieldname, '@', '_circa_');
fieldname = strrep(fieldname, '#', '_hash_');
fieldname = strrep(fieldname, '$', '_dollar_');
fieldname = strrep(fieldname, '%', '_pct_');
fieldname = strrep(fieldname, '^', '_caret_');
fieldname = strrep(fieldname, '&', '_andsand_');
fieldname = strrep(fieldname, '*', '_star_');
fieldname = strrep(fieldname, '(', '_lparen_');
fieldname = strrep(fieldname, ')', '_rparen_');
fieldname = strrep(fieldname, '-', '_dash_');
fieldname = strrep(fieldname, '+', '_plus_');
fieldname = strrep(fieldname, '=', '_eq_');
fieldname = strrep(fieldname, '[', '_lbraket_');
fieldname = strrep(fieldname, ']', '_rbraket_');
fieldname = strrep(fieldname, '{', '_lbrace_');
fieldname = strrep(fieldname, '}', '_rbrace_');
fieldname = strrep(fieldname, '|', '_OR_');
fieldname = strrep(fieldname, '\', '_bslash_');
fieldname = strrep(fieldname, ';', '_semi_');
fieldname = strrep(fieldname, ':', '_colon_');
fieldname = strrep(fieldname, '<', '_lt_');
fieldname = strrep(fieldname, '>', '_gt_');
fieldname = strrep(fieldname, '?', '_que_');
fieldname = strrep(fieldname, '/', '_fslash_');
fieldname = strrep(fieldname, '.', '_dot_');
fieldname = strrep(fieldname, '`', '_sharp_');
