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


function [imageNumberGT,scores] = getLabelbasedScores(e, Task, inpath, theInFiles, imageNumber, experimentNumber)  
% calculate scores when GT and user result are given as label images.
%
% outputs have all the same length, i.e. the number of gt-files available
% for this experiment

    if nargin < 3
        inpath = [];
    end
    % determine number of ground truth files for statistics
    subfolderName = Task.Foldernames{e};
    filePattern = fullfile(Task.gtpath, subfolderName , Task.GTFilePattern);
    theGtFiles = dir(filePattern);
    M = length(theGtFiles); % number of ground truth files

    % init result tables
    imageNumberGT = zeros(M,1);
    scores = zeros(M,length(Task.Measures));

    % loop over the gt files
    for k=1:M
        % get FileName and read gt label image
        gtBaseFileName = theGtFiles(k).name; 
        gtFileName = fullfile(  Task.gtpath, subfolderName, gtBaseFileName);
        gtLabel = imread(gtFileName);
        
        % parse for last number in file name 
        nums = textscan(gtBaseFileName,'%*[^0123456789]%d');
        imageNumberGT(k) = nums{end}(end);

        % print comment
        fprintf(1, 'Processing experiment %s image number %d ...', subfolderName, imageNumberGT(k));

        inLabel = []; % needed to check if inLabel has been created properly
        % check if an input image for imageNumberGT(k) is available
        if ~isempty(inpath)
            currIdx = find( experimentNumber==e & imageNumber==imageNumberGT(k),1);
            if ~isempty(currIdx)            
                % load available image
                inBaseFileName = theInFiles(currIdx).name; 
                inFileName = fullfile(inpath, inBaseFileName);
                inLabel = imread(inFileName);
                % if inLabel is not an index image, make it one
                sz = size(inLabel);
                if(length(sz)>2) % inLabel seems to be a color image: convert!
                    % check if grey image in 24bit
                    mx1 = max(abs(inLabel(:,:,1)-inLabel(:,:,2)));
                    mx2 = max(abs(inLabel(:,:,1)-inLabel(:,:,3)));
                    mx = max(mx1(:)+mx2(:));
                    if(mx>0.5) % colored label image
                        [inLabel,~] = rgb2ind(inLabel, 65536,'nodither');
                    else % grey image
                        inLabel = rgb2gray(inLabel);
                    end
                end
            end
        end
        if isempty(inLabel)
            % create an all zero label image
            inLabel = zeros(size(gtLabel));        
            % print warning and continue
            fprintf(1, ' no label image available ...');
        end

        % if size of imLabel is not size of gtLabel, try to interpolate
        if(max(size(inLabel)~=size(gtLabel)))
            fprintf(1, 'wrong size of label image, interpolate  ...');
            inLabel = imresize(inLabel,size(gtLabel),'nearest');
        end        
 
        % calculate performance measures
        gtLabel = CondenseLabels(gtLabel); % some performance measures need consecutive labelling
        inLabel = CondenseLabels(inLabel);
        
        % loop through the measures defined for the given task
        for measure = 1:length(Task.Measures)
            scores(k,measure) = Task.Measures{measure}(inLabel,gtLabel);
        end
        
        % print comment
        fprintf(1, ' done.\n');
    end
return
    