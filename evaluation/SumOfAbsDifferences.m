%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum J�lich
%   Contact: h.scharr@fz-juelich.de
%   Date: 02.02.2016 
%
% Copyright 2016, Forschungszentrum J�lich GmbH, 52425 J�lich, Germany
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
% Forschungszentrum J�lich GmbH not be used in advertising or publicity 
% pertaining to distribution of the software without specific, written 
% prior permission of the author available under above contact.
% The author preserves the rights to request the deletion or cancel of 
% non-authorized advertising and /or publicity activities.
%
% For intentions of commercial use please contact 
%
% Forschungszentrum J�lich GmbH
% To the attention of Hans-Werner Klein
% Department Technology-Transfer
% Wilhelm-Johnen-Stra�e
% 52428 J�lich
% Germany
%
%
% THE AUTHOR AND FORSCHUNGSZENTRUM J�LICH GmbH DISCLAIM ALL WARRANTIES WITH 
% REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF 
% MERCHANTABILITY AND FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT 
% SHALL THE AUTHOR OR FORSCHUNGSZENTRUM J�LICH GmbH BE LIABLE FOR ANY SPECIAL,  
% INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING 
% FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
% NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
% THE USE OR PERFORMANCE OF THIS SOFTWARE.  
%
% In case of arising software bugs neither the author nor Forschungszentrum 
% J�lich GmbH are obliged for bug fixes and other kinds of support.

function out = SumOfAbsDifferences(A,B)
% calculate sum of A-B
% A and B must have the same size

if isempty(A)
    out = sum(abs(B(:)));
elseif isempty(B)
    out = sum(abs(A(:)));
elseif (sum(abs(size(A)-size(B))))
    % matrices have different size
    warning('Matrices have different size! Results may not be as expected!');
    % output result as if one of the matrices would be empty
    out = max(sum(abs(A(:))),sum(abs(B(:))));
else
    out = sum(abs(A(:)-B(:)));
end

