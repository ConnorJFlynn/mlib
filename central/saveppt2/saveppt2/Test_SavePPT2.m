clear;clc;close all;delete('test.ppt');
a=figure('Visible','off');plot(1:10);
b=figure('Visible','off');plot([1:10].^2);
c=figure('Visible','off');plot([1:10].^3);
d=figure('Visible','off');plot([1:10].^4);
%% Test Basic Plots
saveppt2('test.ppt','f',0,'t','Test Basic Plots')
saveppt2('test.ppt','f',a)
saveppt2('test.ppt','fig',b)
saveppt2('test.ppt','figure',c)
saveppt2 test.ppt -f 1 % Can't use variable because a will not be evaluated when called like this.
%% Test all scaling & stretching options
saveppt2('test.ppt','f',0,'t','Test all scaling & stretching options')
for scaling=[true false]
    for stretching=[true false]
        saveppt2('test.ppt','figure',a,'scale',scaling,'stretch',stretching)
    end
end
%% Test the columns w/scaling and stretching
saveppt2('test.ppt','f',0,'t','Columns w/scaling & stretching')
for scaling=true % If more than 1 plot is given, scaling is automatically enabled to fit plots.
    for stretching=[true false]
        for i=1:4
            saveppt2('test.ppt','figure',[a b c d],'columns',i,'scale',scaling,'stretch',stretching)
        end
    end
end

%% Test the columns with a title
saveppt2('test.ppt','f',0,'t','Columns with Title')
for i=1:4
    saveppt2('test.ppt','figure',[a b c d],'columns',i,'title',['Columns ' num2str(i)])
end

%% Test padding
saveppt2('test.ppt','f',0,'t','Test Padding')
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',20)
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[20 0 0 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 20 0 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 0 20 0])
saveppt2('test.ppt','figure',[a b c d],'columns',2,'padding',[0 0 0 20])

%% Test renderers
saveppt2('test.ppt','f',0,'t','Test Renderers')
saveppt2('test.ppt','figure',[a b],'render','painters')
saveppt2('test.ppt','figure',[a b],'render','zbuffer')
saveppt2('test.ppt','figure',[a b],'render','opengl')

%% Two Figure alignment tests
% Test alignment
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',[a b],'halign',halign,'valign',valign,'stretch',false)
    end
end
% Test alignment w/title
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment w/title')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',[a b],'title',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false)
    end
end
% Test alignment w/notes
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment w/notes')

for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',[a b],'notes',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false)
    end

end
% Test alignment w/textbox
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment w/textbox')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',[a b],'visible','textbox',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false)
    end
end
%% Test alignment w/comments
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment w/textbox')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',[a b],'visible','comments',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false)
    end
end
%% One Figure alignment tests
% Test alignment
saveppt2('test.ppt','f',0,'t','1 Fig. Alignment')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',a,'halign',halign,'valign',valign,'stretch',false,'scale',false);
    end
end
% Test alignment w/title
saveppt2('test.ppt','f',0,'t','1 Fig. Alignment w/title')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',b,'title',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false,'scale',false);
    end
end
% Test alignment w/notes
saveppt2('test.ppt','f',0,'t','1 Fig. Alignment w/notes')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',c,'notes',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false,'scale',false);
    end
end
% Test alignment w/textbox
saveppt2('test.ppt','f',0,'t','1 Fig. Alignment w/textbox')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',d,'textbox',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false,'scale',false);
    end
end
% Test alignment w/comments
saveppt2('test.ppt','f',0,'t','2 Fig. Alignment w/textbox')
for halign={'left','right','center'}
    for valign={'top','bottom','center'}
        saveppt2('test.ppt','figure',a,'visible','comments',[halign{1} ' ' valign{1}],'halign',halign,'valign',valign,'stretch',false,'scale',false)
    end
end
%% Direct input text parameters.
%% Test Notes
saveppt2('test.ppt','f',0,'t','Notes - direct')
saveppt2('test.ppt','notes','Hello World!');
saveppt2('test.ppt','notes','Hello World!\nLine Two');
saveppt2('test.ppt','notes','Hello World!\n\tRow Two, Tabbed');

%% Test TextBox
saveppt2('test.ppt','f',0,'t','Textbox - direct')
saveppt2('test.ppt','text','Hello World!');
saveppt2('test.ppt','textbox','Hello World!\nLine Two');
saveppt2 test.ppt -text 'Hello World!\n\tRow Two, Tabbed';

%% Test Comments
saveppt2('test.ppt','f',0,'t','Comments - direct')
saveppt2('test.ppt','comment','Hello World!','visible');
saveppt2('test.ppt','comments','Hello World!\nLine Two','visible');
saveppt2 test.ppt -comment 'Hello World!\n\tRow Two, Tabbed' 'visible'

%% All in one
saveppt2('test.ppt','f',0,'t','All text parameters')
saveppt2('test.ppt','notes','This is a note','textbox','This is a textbox','comments','This is the comment','visible');

%% Sprintf input text parameters.
%% Test Notes
saveppt2('test.ppt','f',0,'t','Notes - Sprintf')
saveppt2('test.ppt','notes',sprintf('Hello World!'));
saveppt2('test.ppt','notes',sprintf('Hello World!\nLine Two'));
saveppt2('test.ppt','notes',sprintf('Hello World!\n\tRow Two, Tabbed'));

%% Test TextBox
saveppt2('test.ppt','f',0,'t','TextBox - Sprintf')
saveppt2('test.ppt','textbox',sprintf('Hello World!'));
saveppt2('test.ppt','text',sprintf('Hello World!\nLine Two'));
saveppt2('test.ppt','textbox',sprintf('Hello World!\n\tRow Two, Tabbed'));

%% Test Comments
saveppt2('test.ppt','f',0,'t','Comments - Sprintf')
saveppt2('test.ppt','comment',sprintf('Hello World!'),'visible');
saveppt2('test.ppt','comments',sprintf('Hello World!\nLine Two'),'visible');
saveppt2('test.ppt','comment',sprintf('Hello World!\n\tRow Two, Tabbed'),'visible');


%% Test Resolution
saveppt2('test.ppt','f',0,'t','Test Resolution')
for i=100:100:500
    saveppt2('test.ppt','resolution',i,'title',['Resolution ' num2str(i)])
end

%% Batch Saving
saveppt2('test.ppt','f',0,'t','Batch Saving')
ppt=saveppt2('test.ppt','init');
saveppt2('ppt',ppt,'figure',a);
saveppt2('ppt',ppt,'figure',b,'notes','This is a note');
saveppt2('ppt',ppt,'figure',c,'textbox','Text Box');
saveppt2('ppt',ppt,'figure',d,'visible','comments','This is a Comment');
saveppt2('test.ppt','ppt',ppt,'close');

%% Driver Types
saveppt2('test.ppt','f',0,'t','Driver Types')
for driver={'meta' 'bitmap'}
    for scaling=[true false]
        for stretching=[true false]
            saveppt2('test.ppt','scale',scaling,'stretch',stretching,'driver',driver{1},'title',['Driver: ' driver{1}],'notes',sprintf('Scaling: %d\nStretching: %d',scaling,stretching))
        end
    end
end

%% Test Close Function of PowerPoint.
% In previous versions of saveppt2, 'leave_open' would be closed without
% saving or warning. PowerPoint should recognize that there is already a
% presentation open and not close it.
try % For some unknown reason, this doesn't always work when called from publish.
    ppt=saveppt2('leave_open.ppt','f',0,'title','Open Presentation','visible','close',false);
    saveppt2('close.ppt','fig',a)
    saveppt2('leave_open.ppt','ppt',ppt,'close',true);
    delete('leave_open.ppt','close.ppt');
catch
end
%% Batch Format vs Regular Benchmark
delete('benchmark.ppt');
try
    for n=[10 50]
        tic
        ppt=saveppt2('benchmark.ppt','init');
        for i=1:n
            saveppt2('ppt',ppt,'title',sprintf('Batch. Plot #%d/%d. Time: %fs',i,n,toc));
        end
        saveppt2('benchmark.ppt','ppt',ppt,'close');
        fprintf('Batch Method. %d Plots: %fs\n',n,toc);
        tic
        for i=1:n
            saveppt2('benchmark.ppt','title',sprintf('Regular. Plot #%d/%d. Time: %fs',i,n,toc));
        end
        fprintf('Original Method. %d Plots: %fs\n\n',n,toc);
    end
catch
end