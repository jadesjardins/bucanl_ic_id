% eegplugin_icID() - EEGLAB plugin for ...
%
% Usage:
%   >> eegplugin_icID(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%
% Creates Plot menu option "IC pvaf identification"... 
%
%
% Copyright (C) <2011> <James Desjardins> Brock University
%
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA



function eegplugin_icID(fig,try_strings,catch_strings)


% find EEGLAB plot menu.
% ---------------------
plotmenu=findobj(fig,'label','Plot');

% Create "pop_icID_pvaf" callback cmd.
%---------------------------------------
icID_cmd='[LASTCOM] = pop_icID_pvaf(ALLEEG);';

% add "IC pvaf identification" submenu to the "Plot" menu.
%--------------------------------------------------------------------
uimenu(plotmenu, 'label', 'IC pvaf identification', 'callback', icID_cmd, 'separator', 'on');
