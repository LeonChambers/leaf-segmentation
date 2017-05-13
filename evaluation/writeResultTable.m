%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 11.01.2016 
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


function writeResultTable(Task, resultName,outpath,username,imageNumberGT,scores,experimentNumber)
% write the result tables
    
    if nargin < 7
        experimentNumber = []; % needed only, when results from multiple experiments are written in the same table
    end
    
    % now just write the results to a csv table
    resultFileName = fullfile(outpath, [username '_' resultName '_results.csv']);
    fprintf(1, 'Writing results to %s\n', resultFileName);
    
    fid = fopen(resultFileName, 'w+');
    fprintf(fid, 'Results for images: %s\n\n', resultName);
    fprintf(fid, 'number');
    for m = 1:length(Task.MeasureNames)
        fprintf(fid, [', ' Task.MeasureNames{m}]);
    end
    if ~isempty(experimentNumber) % multiple experiments
        fprintf(fid, ', experiment');    
    end
    fprintf(fid, '\n');    
    
    M = length(imageNumberGT);
    
    for k=1:M
        fprintf(fid, '%d', imageNumberGT(k));
        for m = 1:length(Task.MeasureNames)
            fprintf(fid, Task.MeasuresFormat{m}, scores(k,m));
        end
        if ~isempty(experimentNumber) % multiple experiments
            fprintf(fid, ', %d',experimentNumber(k));
        end
        fprintf(fid, '\n');
    end
    
    % some statistics...
    fprintf(fid, '\n');
    printstatistics(fid, @mean, 'mean', scores);
    printstatistics(fid, @median, 'median', scores);
    printstatistics(fid, @max, 'max', scores);
    printstatistics(fid, @min, 'min', scores);
    
    fclose(fid);

function printstatistics(fid, func, name, scores)
    M = size(scores,2);
    fprintf(fid, name);
    for m = 1:M
        fprintf(fid, ', %f', func(scores(:,m)));
    end
    fprintf(fid, '\n');
    
