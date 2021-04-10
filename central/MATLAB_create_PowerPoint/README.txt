This example was prepared using MATLAB 7.3 (R2006b) on a 32-bit winXPsp2 platform. It is an example of using ACTXSERVER to open & control Microsoft Office 2003 PowerPoint 2003. There are two options for using MATLAB to create PowerPoint slides:



1. Use the "Publish To" option in the MATLAB Editor. Consider an m-file in the MATLAB Editor, for example:

a = [1:10];
b = [1:10].^2;
plot(a,b,'b.')

In the MATLAB Editor menu, choose "File" -> "Publish To". You have your choice of HTML, XML, LaTeX, Word Document, or PowerPoint presentation. An advantage of this option is simplicity; a disadvantage is that you have limited control over the output format.



2. Open PowerPoint as a COM Automation server (Windows platforms only). See "pptwrite.m".