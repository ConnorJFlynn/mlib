function f = newFolder(this,foldername)
%KML.NEWFOLDER(folderName) Creates a folder inside an kml (or another folder).
%  The folder behaves exactly as a KML object. 
%  Example of use:
%  k = kml;
%  f = kml.createFolder('My Folder');
%  t = linspace(0,2*pi,1000);
%  f.plot(t,sin(t));
%  k.run
%
%   Copyright 2012 Rafael Fernandes de Oliveira (rafael@rafael.aero)
%   $Revision: 1.1 $  $Date: 2013/12/11 04:35:18 $

    if nargin < 2
        foldername = 'Unnamed Folder';
    end
    f = kml(foldername,this);
end