%% Open PowerPoint as a COM Automation server

h = actxserver('PowerPoint.Application')
% Show the PowerPoint window
h.Visible = 1;

% What attributes and operations are available for the handle "h"?  These
% are attributes and operations of the PowerPoint object ... and are
% documented in the PowerPoint Visual Basic Reference. Bring up the
% PowerPoint session help window:
h.Help

% Not that PowerPoint documentes in VBA syntax ... so operation signatures
% may need a little translating.


%% ADD PRESENTATION
% View the methods that can be invoked
h.Presentation.invoke

% Add a presentation via "Add" method
Presentation = h.Presentation.Add


%% ADD SLIDES
% View the methods that can be invoked
Presentation.Slides.invoke

% Add two slides via "Add" method
Slide1 = Presentation.Slides.Add(1,'ppLayoutBlank')
Slide2 = Presentation.Slides.Add(2,'ppLayoutBlank')


%% GENERATE MATLAB IMAGES, SAVE AS .PNG
% The mechanism chosen here is to save images to disk and then import into
% PowerPoint from a disk file.
f1 = figure;
plot(1:10)
print('-dpng','-r150','test1.png')
close( f1 )

f2 = figure;
image(ceil(64*rand(20,20)))
print('-dpng','-r150','test2.png')
close( f2 )


%% ADD IMAGES TO SLIDES
% Add images - *Full path names should be used*
Image1 = Slide1.Shapes.AddPicture('C:\...\test1.png','msoFalse','msoTrue',100,20,500,500)
Image2 = Slide2.Shapes.AddPicture('C:\...\test2.png','msoFalse','msoTrue',100,20,500,500)

% Add titles
Title1 = Slide1.Shapes.AddTextbox('msoTextOrientationHorizontal',200,10,400,70)
Title1.TextFrame.TextRange.Text = 'plot(1:10)'

Title2 = Slide2.Shapes.AddTextbox('msoTextOrientationHorizontal',200,10,400,70)
Title2.TextFrame.TextRange.Text = 'image(ceil(64*rand(20,20)))'


%% SAVE PRESENTATION
% *Full path name should be used*
Presentation.SaveAs('C:\...\ExamplePresentation.ppt')


%% CLEAN UP
% Terminate the server session to which the handle is atttached
h.Quit;
% Release all interfaces derived from the server
h.delete;