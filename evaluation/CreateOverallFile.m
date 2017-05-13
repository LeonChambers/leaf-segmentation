%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 10.02.2016 (Version 2)
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


function CreateOverallFile(Task,inpath,outpath)
% CreateOverallFile(Task,inpath,outpath) creates a summary CSV file in
% 'outpath' from all result files in 'inpath'. File name convention and 
% format is defined in the struct 'Task'.

    N = length(Task.Foldernames);
    % count gt files and create indices of result blocks per experiment
    % accordingly
    idx = zeros(N+1,1);
    idx(1)=1;
    for e=1:N
        idx(e+1) = idx(e)+getNumberOfGtResults(Task,e);
    end
    overallNum = idx(N+1)-1;
    
    % init score table
    M = length(Task.Measures);  
    ScoresAll = zeros(overallNum,M);
    imageNumberAll = zeros(overallNum,1);
    experimentNumberAll = zeros(overallNum,1);

    if Task.evalMultipleExperiments>0
        % multiple experiments
        % loop usernames (or experiment names), i.e. directory names
        [dirNames,dirNumber] = getDirNames(inpath);
    else
        % single experiment, all subfolders belong to the same experiment
        dirNames{1} = Task.prefix; % use prefix instead of directory name
        dirNumber = 1;
    end
    for i=1:dirNumber
        for e=1:N % loop experiments
            % index positions to fill in score table
            pos = idx(e):idx(e+1)-1;
            experimentNumberAll(pos)=e;
            % check if result file for this experiment exists
            resBaseName = [dirNames{i} '_' Task.Foldernames{e} '_results.csv'];
            resFileName = fullfile(outpath, resBaseName);
            r = dir(resFileName);
            if ~isempty(r) % if file exists, process it, else generate results
                 [imageNumberAll(pos),ScoresAllPos] ...
                     = parseResultCSV(Task,resFileName);
                 ScoresAll(pos,:) = ScoresAllPos;
            else
                % no results available, generate scores for empty results
                
                
                % switch through different measure types
                if strcmp(Task.ScoreType,'one_label_image_per_image')
                    [imageNumberAll(pos),ScoresAllPos] = getLabelbasedScores(e,Task);  
                elseif strcmp(Task.ScoreType,'one_table_per_image')
                    [imageNumberAll(pos),ScoresAllPos] = getTablebasedScores(e,Task);  
                elseif strcmp(Task.ScoreType,'one_table_per_directory')
                    [imageNumberAll(pos),ScoresAllPos] = getSummarizedTablebasedScores(e,Task);  
                else
                    error('Error: Unknown score type! Aborting!');
                end                
                ScoresAll(pos,:) = ScoresAllPos;
                % write score table for this experiment to file
                writeResultTable(Task, Task.Foldernames{e},outpath,dirNames{i},imageNumberAll(pos),ScoresAllPos);
            end
        end
        % write score table for all experiments to file
        writeResultTable(Task,'all',outpath,dirNames{i},imageNumberAll,ScoresAll,experimentNumberAll);
        % write the required LaTeX table
        writeLaTeXTable(Task, outpath,dirNames{i},ScoresAll,experimentNumberAll);
    end
return    

% helper function: get number of label files in a directory
function Number = getNumberOfGtResults(Task, idx)
    filePattern = fullfile(Task.gtpath, Task.Foldernames{idx}, Task.GTFilePattern);
    theFiles = dir(filePattern);
    if strcmp(Task.ScoreType,'one_table_per_directory')
        % one file for all images. Count entries of file.
        filename = fullfile(Task.gtpath, Task.Foldernames{idx}, theFiles(1).name);
        fileID = fopen(filename);
        C = textscan(fileID,'%s','Delimiter','\n');
        fclose(fileID);
        Number = size(C{1},1);
    else
        % one file per image. Count files.
        Number = length(theFiles); % number of ground truth files
    end
return

% get number of directories in a folder, without '.' and '..'
function [DirNames,DirNumber] = getDirNames(inpath)
    filePattern = fullfile(inpath, '*');
    theFiles = dir(filePattern);
    M = length(theFiles); % number of ground truth files
    % count directories without '.' and '..'
    DirNames = cell(M,1);
    DirNumber = 0;
    for k = 1:M
      if theFiles(k).isdir;
        dirName = theFiles(k).name; 
        if dirName(1) ~= '.'            
            DirNumber = DirNumber+1;
            DirNames{DirNumber}=dirName;
        end
      end
    end
return

% parse a result table file and read scores
function [imageNumberGT,ScoresGT] = parseResultCSV(Task, filename)

    % create format string for textscan
    formatString = '%d';
    numFields = length(Task.MeasuresFormat);
    for i=1:numFields
        formatString = [formatString Task.MeasuresFormat{i}];
    end

    % read file
    fid = fopen(filename);
    fscanf(fid, '%s',5+numFields); % skip header    
    C = textscan(fid, formatString); % read data
    fclose(fid);

    % copy read data to output
    imageNumberGT = C{1};    
    ScoresGT = zeros(length(imageNumberGT),numFields);
    for i=1:numFields
        ScoresGT(:,i) = C{i+1};
    end
return
         
function writeLaTeXTable(Task, outpath, username, ScoresAll, experimentNumber)
    M = length(Task.Measures); % number of measures
    
    % now just write the results to a csv table
    resultFileName = fullfile(outpath, [username '_results.tex']);
    fprintf(1, 'Writing results to %s\n', resultFileName);
    
    fid = fopen(resultFileName, 'w+');

    fprintf(fid, '\\begin{tabular}{|l||');
    for m=1:M
        fprintf(fid, 'c|');
    end
    fprintf(fid, '}\n');
    fprintf(fid, '\\hline\n');
    for m=1:M
        fprintf(fid, [' & \\bf{' Task.MeasureNames{m} ' ' Task.LatexUnits{m} '}']);
    end
    fprintf(fid, '\\\\\n');
    fprintf(fid, '\\hline\n');
    fprintf(fid, '\\hline\n');

    % mean and std dev for each experiment
    for e=1:length(Task.Foldernames)
        idx = find(experimentNumber==e);
        fprintf(fid, '\\bf{%s}', Task.Foldernames{e});
        for m=1:M
            fprintf(fid, [' & ' Task.LatexStatsFormat{1} ' ($\\pm$' Task.LatexStatsFormat{2} ')'], ...
            mean(Task.LatexUnitsFactor{m}*ScoresAll(idx,m)),Task.LatexUnitsFactor{m}*std(ScoresAll(idx,m)));                
        end
        fprintf(fid, '\\\\\n');
        fprintf(fid, '\\hline\n');
    end
    % overall mean and std dev
    fprintf(fid, '\\bf{all}');
    for m=1:M
        fprintf(fid, [' & ' Task.LatexStatsFormat{1} ' ($\\pm$' Task.LatexStatsFormat{2} ')'], ...
        mean(Task.LatexUnitsFactor{m}*ScoresAll(:,m)),Task.LatexUnitsFactor{m}*std(ScoresAll(:,m)));                
    end
    fprintf(fid, '\\\\\n');

    fprintf(fid, '\\hline\n');
    fprintf(fid, '\\end{tabular}\n');
    
    fclose(fid);
return