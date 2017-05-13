%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 21.12.2015
%
% Copyright 2015, Forschungszentrum Jülich GmbH, 52425 Jülich, Germany
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


function outLabel = CondenseLabels(inLabel)
% inLabel:  a label image
% outLabel: a label image with same size as inLabel, but consecutive
%           forground labelling
%
% CondenseLabel moves forground labels in range [1,...,N] when N different 
% forground labels, i.e. labels >0, are found in the label image inLabel. 
% Keeps label order.


maxInLabel = max(inLabel(:)); % maximum label value in inLabel
minInLabel = max(min(inLabel(:)),1); % minimum label value in inLabel

A = minInLabel:maxInLabel;
Lia = ismember(A,inLabel(:));

if(isempty(A) || (minInLabel<=1 && min(Lia)>0)) 
    % no relabelling needed
    outLabel = inLabel;
else
    outLabel = zeros(size(inLabel));
    consLabel = 1;
    for label = 1:length(Lia)
        if Lia(label)
            % label available in inLabel
            inMask = (inLabel==label); % find region of label in inLabel
            outLabel(inMask) = consLabel;
            consLabel = consLabel+1;
        end
    end
end
