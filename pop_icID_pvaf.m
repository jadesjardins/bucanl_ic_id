% pop_icID_pvaf() - Collect variables for ...
%
% Usage: 
%   >>  EEG = pop_icID_pvaf( EEG, ChanIndex, EventType);
%
%   ChanIndex   - EEG channels to display in eegplot figure window while editing events and identifying bad channels.
%   EventType   - Event types to display in eegplot figure window while editing events and identifying bad channels.
%    
% Outputs:
%   EEG  - output dataset
%
% UI for selecting EEG channels and event types to be displayed in eegplot
% figure window while editing events and identifying bad channels.
%
% Calls function EEG=VisEd(EEG,ChanIndex,EventType);
%
% See also:
%   EEGLAB 

% Copyright (C) <2008>  <James Desjardins> Brock University
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

function [ALLEEG,com]=pop_icID_pvaf(ALLEEG,sets,times,comps,varargin)


% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            
          % display help if not enough arguments
% ------------------------------------

if nargin < 1
	help pop_icID_pvaf;
	return;
end;	


% pop up window
% -------------
if nargin < 4

    icinds=1:size(ALLEEG(1).icaweights,1);
    for i=1:length(icinds);icindsCell{i}=num2str(icinds(i));end
    
    results=inputgui( ...
    {[1] [1] [4 4 2] [4 4 2] [4 4 2] [4 4 2] [1] [1] [1]}, ...
    {...
        ... %1
        {'Style', 'text', 'string', 'Enter parameters for IC pvaf identification.', 'FontWeight', 'bold'}, ...
        ... %2
        {}, ...
        ... %3
        {'Style', 'text', 'string', 'Sets to use:'}, ...
        {'Style', 'edit', 'string', vararg2str(1:length(ALLEEG)),'tag', 'SetsIndexEdit'}, ...
        {'Style', 'pushbutton', 'string', '...', 'tag', 'SetsIndButton',... 
                  'callback', ['[SetsIndex,SetsStr,SetsCell]=pop_chansel({ALLEEG.setname});' ...
                  'set(findobj(gcbf, ''tag'', ''SetsIndexEdit''), ''string'', vararg2str(SetsIndex))']}, ...
        ... %4
        {'Style', 'text', 'string', 'Sites to include:'}, ...
        {'Style', 'edit', 'string', vararg2str(1:ALLEEG(1).nbchan),'tag', 'ChanIndexEdit'}, ...
        {'Style', 'pushbutton', 'string', '...', 'tag', 'ChanLabelButton',... 
                  'callback', ['icinds=1:size(ALLEEG(1).icaweights,1);' ...
                  'for i=1:length(icinds);icindsCell{i}=num2str(icinds(i));end;' ...
                  '[ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel({EEG.chanlocs.labels});' ...
                  'set(findobj(gcbf, ''tag'', ''ChanIndexEdit''), ''string'', vararg2str(ChanLabelIndex))']}, ...
        ... %4
        {'Style', 'text', 'string', 'ICs to include:'}, ...
        {'Style', 'edit', 'string', vararg2str(1:size(ALLEEG(1).icaweights,1)),'tag', 'ICsIndexEdit'}, ...
        {'Style', 'pushbutton', 'string', '...', 'tag', 'ICsLabelButton',... 
                  'callback', ['[ICsLabelIndex,ICsLabelStr,ICsLabelCell]=pop_chansel(icindsCell);' ...
                  'set(findobj(gcbf, ''tag'', ''ICsIndexEdit''), ''string'', vararg2str(ICsLabelIndex))']}, ...
        ... %4
        {'Style', 'text', 'string', 'Time interval to use:'}, ...
        {'Style', 'edit', 'string', '100 200'}, ...
        {}, ...
        ... %6
        {'Style', 'text', 'string', 'Optional inputs:'}, ...
        ... %7
        {'Style', 'edit', 'string', ''}, ...
        ... %8
        {}, ...
     }, ...
     'pophelp(''pop_icID_pvaf'');', 'Select pvaf ID parameters -- pop_icID_pvaf()' ...
     );
 
     if isempty(results);return;end
     
     sets=str2num(results{1});
     chans=str2num(results{2});
     comps=str2num(results{3});
     times=str2num(results{4});
     opts=results{5};
end


% return command
% -------------------------
if isempty(opts)
    com=sprintf('pop_icID_pvaf( %s, %s, %s, %s, %s);', inputname(1), vararg2str(sets), vararg2str(times), vararg2str(comps),vararg2str(chans))
else
    com=sprintf('pop_icID_pvaf( %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(sets), vararg2str(times), vararg2str(comps),vararg2str(chans), opts)
end    
% call command
% ------------
if isempty(opts)
    exec=sprintf('icID_pvaf( %s, %s, %s, %s, %s);', inputname(1), vararg2str(sets), vararg2str(times), vararg2str(comps),vararg2str(chans));
else
    exec=sprintf('icID_pvaf( %s, %s, %s, %s, %s, %s);', inputname(1), vararg2str(sets), vararg2str(times), vararg2str(comps),vararg2str(chans), opts);
end

eval(exec);


return;
