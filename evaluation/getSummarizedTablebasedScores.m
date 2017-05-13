%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 02.02.2016 
%
% Copyright 2016, Forschungszentrum Jülich GmbH, 52425 Jülich, Germany
% 
%                          All Rights Reserved
% 
% All commercial use of this software, whether direct or indirect, is
% strictly prohibited including, without limitation, incorporation into in
% a commercial product, use in a commercial service, or production of other
% artifacts for commercial purposes.     
%
% Permission to use, copy, modify, and distribute this software and its
% documentation worldwide for research purposes solely is hereby granted 
% without fee, provided that the above copyright notice appears in all 
% copies and that both that copyright notice and this permission notice 
% appear in supporting documentation, and that the name of the author and 
% Forschungszentrum Jülich GmbH not be used in advertising or publicity 
% pertaining to distribution of the software without specific, written 
% prior permission of the author available under above contact.
% The author preserves the rights to request the deletion or cancel of 
% non-authorized advertising and /or publicity activities.
%
% For intentions of commercial use please contact 
%
% Forschungszentrum Jülich GmbH
% To the attention of Hans-Werner Klein
% Department Technology-Transfer
% Wilhelm-Johnen-Straße
% 52428 Jülich
% Germany
%
%
% THE AUTHOR AND FORSCHUNGSZENTRUM JÜLICH GmbH DISCLAIM ALL WARRANTIES WITH 
% REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF 
% MERCHANTABILITY AND FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT 
% SHALL THE AUTHOR OR FORSCHUNGSZENTRUM JÜLICH GmbH BE LIABLE FOR ANY SPECIAL,  
% INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING 
% FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
% NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
% THE USE OR PERFORMANCE OF THIS SOFTWARE.  
%
% In case of arising software bugs neither the author nor Forschungszentrum 
% Jülich GmbH are obliged for bug fixes and other kinds of support.


function [imageNumberGT,scores] = getSummarizedTablebasedScores(e, Task, inpath, theInFiles, imageNumber, experimentNumber)  
% calculate scores when GT and user result are given as tables.
%
% outputs have all the same length, i.e. the number of gt-files available
% for this experiment

    if nargin < 3
        inpath = [];
    end
    % determine number of ground truth entries for statistics
    subfolderName = Task.Foldernames{e};
    
    % print comment
    fprintf(1, 'Processing experiment %s ...', subfolderName);
    
    filePattern = fullfile(Task.gtpath, subfolderName , Task.GTFilePattern);
    theGtFiles = dir(filePattern);
    % only 1 summary table per folder allowed, thus, use first one and warn
    if(isempty(theGtFiles))
        return
    elseif(length(theGtFiles)>1)
        gtBaseFileName = theGtFiles(1).name; 
        warning('More than 1 summary ground truth table found in subfolder %s. Using %s ...',subfolderName,gtBaseFileName);
    end

   % get FileName and read gt table
    gtBaseFileName = theGtFiles(1).name; 
    gtFileName = fullfile(  Task.gtpath, subfolderName, gtBaseFileName);    
    
    % read gt table
    N_before = Task.gtTableSkipBefore;
    N_data   = Task.gtTableNumData;
    N_after  = Task.gtTableSkipAfter;
    [gtTable,imageNumberGT] = read_table(N_before,N_data,N_after, gtFileName, Task.gtTableDelimiter,...
        Task.gtTableColumnOfImageName,Task.gtTableColumnOfImageNumber);
    
    inTable = []; % needed to check if inTable has been created properly
    imageNumberIn = [];
    % check if an input table for gtTable is available
    if ~isempty(inpath)
        currIdx = find( experimentNumber==e,1);
        if ~isempty(currIdx)            
            % compose filename
            inBaseFileName = theInFiles(currIdx).name; 
            inFileName = fullfile(inpath, inBaseFileName);

            % read table
            N_before = Task.inTableSkipBefore;
            N_data   = Task.inTableNumData;
            N_after  = Task.inTableSkipAfter;

            [inTable,imageNumberIn] = read_table(N_before,N_data,N_after, inFileName, Task.inTableDelimiter,...
                Task.inTableColumnOfImageName,Task.inTableColumnOfImageNumber);
        end
    end          
    if isempty(inTable)
        % print warning and continue
        fprintf(1, ' no table available ...');
    end
    
    M = size(gtTable,1); % number of entries in ground truth file
    % init result tables
    scores = zeros(M,length(Task.Measures));

    % if image number is given in gtTable, use it, if not, simply enumerate
    if(isempty(imageNumberGT))
        imageNumberGT=[1:M];
    end
    
    N = size(inTable,1); % number of entries in inTable
    % if image number is given in inTable, use it, if not, simply enumerate
    if(isempty(imageNumberIn))
        imageNumberIn=[1:N];
    end
    
    % loop over the entries of gtTable
    for k=1:M
        % find corresponding lines in gt- and inTable
        K = imageNumberGT(k); % image number
        gtLine = gtTable(k,:);
        inLine = [];
        if ~isempty(inTable)
            % find line in inTable corresponding to gtLine.i.e. same image number
            lineidx = find(imageNumberIn==K);
            if ~isempty(lineidx)
                inLine = inTable(lineidx,:);
            end
        end
        
        % loop through the measures defined for the given task
        for measure = 1:length(Task.Measures)
            scores(k,measure) = Task.Measures{measure}(inLine,gtLine);
        end
        
    end
    % print comment
    fprintf(1, ' done.\n');
return
    
