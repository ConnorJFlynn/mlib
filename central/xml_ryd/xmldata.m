% XMLDATA   - Read a XML tag or text at a given position in a XML file.
%
% [name,data,type,p]=xmldata('xmlstring',p)
%
% This is implemented as a mex file to get better speed. Look at the source of
% xmlstruct to better understand how to use it. p is an variable that
% specify where to read and and then were to continue read of next tag.
%
% SE ALSO: XMLSTRUCT
%
% Look at:  http://www.rydesater.com/tools OR http://petrydpc.ite.mh.se/tools
% 
%   LICENSE:
%  ========= 
%
%   Copyright (C) Peter Rydesäter 2002, Mitthögskolan, SWEDEN
%
%   This program is free software; you can redistribute it and/or
%   modify it under the terms of the GNU General Public License
%   as published by the Free Software Foundation; either version 2
%   of the License, or (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%   
%
%   Please, send me an e-mail if you use this and/or improve it. 
%   If you think this is usful fore your work, please remember me and my
%   hard work with it!
%
%   Peter.Rydesater@mh.se
%
%   Peter Rydesäter
%   Mitthögskolan (Mid Sweden University)
%   SE-831 25 ÖSTERSUND
%   SWEDEN
%



  
  

