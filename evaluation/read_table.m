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

function [Table, ImageNumbers] = read_table(N_before,N_data,N_after, filename, delimiter, IdxImageName, IdxImageNumber)

    if nargin < 6
        IdxImageName = 0;
    end
    if nargin < 7
        IdxImageNumber = 0;
    end

    % init
    Table = [];
    ImageNumbers = [];
    
    % compose format string
    formatstring = [repmat('%f',[1,N_before]),repmat('%f',[1,N_data]),repmat('%f',[1,N_after])];
    if( IdxImageName > 0) % add a '%s' where needed
        Idx = IdxImageName;
        formatstring = [formatstring(1:2*Idx-2), '%s' , formatstring(2*Idx-1:end)];
    end
    % read the available table and extract data for evaluation
    fileID = fopen(filename);
    C = textscan(fileID,formatstring,'Delimiter',delimiter);
    fclose(fileID);

    if( IdxImageName > 0) % extract string from cell array C
        filenames = C{IdxImageName};
        C(:,IdxImageName) = []; % remove cells from cell array
        % parse image names for image numbers
        ImageNumbers = zeros(length(filenames),1);
        for i=1:length(filenames)
            nums = textscan(filenames{i},'%*[^0123456789]%d');
            if ~isempty(nums{end})
                ImageNumbers(i) = nums{end}(end);
            end
        end

    end

    A = cell2mat(C); % for easier handling of the data
    Cols = size(A,2);% # columns of the table
    if Cols >= N_before+N_data
        Table = A(:,N_before+1:N_before+N_data); % remove preceeding numbers, if any
    else
        warning('file %s input table has fewer entries per line as expected ...',filename);
    end
    if( IdxImageNumber > 0 && IdxImageNumber < Cols)
        ImageNumbers = A(:,IdxImageNumber);
    end
    
return