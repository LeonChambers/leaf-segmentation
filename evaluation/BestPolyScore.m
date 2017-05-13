%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 01.02.2016
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
 
function score = BestPolyScore(inPoly,gtPoly,ScoreFun)
% inPoly: table with polygons to be evaluated. 
% gtPoly: ground truth polygons.
% score: maximum value given by ScoreFun.
%
% For the original Dice score or Overlap score, regions corresponding to each other need to
% be known in advance. Here we simply take the best matching regions from 
% gtTable in each comparison. We do not make sure that a region from
% gtTable is used only once. Better measures may exist. 
% Please enlighten me if I do something stupid here...

    score = 0; % initialize output

    maxIn = size(inPoly,1); % number of polygons in inTable
    maxGT = size(gtPoly,1); % number of polygons in gtTable

    if(maxIn==0) % trivial solution
        return
    end

    for i=[1:maxIn]; % loop all bboxes of inTable
        sMax = 0; % maximum Dice value found for polygon i so far
        for j=[1:maxGT] % loop all polygons of gtTable
            s = PolyScore(inPoly, gtPoly, i, j,ScoreFun); % compare labelled regions
            % keep max Dice value for polygon i
            if(sMax < s)
                sMax = s;
            end
        end
        score = score + sMax; % sum up best found values
    end
    score = score/double(maxIn);


function out = PolyScore(inPoly, gtPoly, i, j,ScoreFun)
% calculate Dice score for the given polygons i and j. I generate masks of
% the image resolution containing the polygons and calculate the usual DICE 
% score.
% Please enlighten me how to do this more efficiently...

    % calculate region covered by bboxes and check overlap
    inpoly = inPoly(i,:);
    inXY = reshape(inpoly,2,length(inpoly)/2);
    gtpoly = gtPoly(j,:);
    gtXY = reshape(gtpoly,2,length(gtpoly)/2);
       
    maxXin = max(inXY(1,:)); minXin = min(inXY(1,:));
    maxYin = max(inXY(2,:)); minYin = min(inXY(2,:));
    maxXgt = max(gtXY(1,:)); minXgt = min(gtXY(1,:));
    maxYgt = max(gtXY(2,:)); minYgt = min(gtXY(2,:));
    
    % check if overlap possible
    if ( (maxXin < minXgt) || (maxXgt < minXin) || ...
         (maxYin < minYgt) || (maxYgt < minYin) )
        % no overlap
        out = 0; 
        return;
    end

    maxX = ceil(max(maxXin,maxXgt));
    minX = floor(min(minXin,minXgt));
    maxY = ceil(max(maxYin,maxYgt));
    minY = floor(min(minYin,minYgt));
    
    % mask size
    DX = maxX - minX + 1;
    DY = maxY - minY + 1;

    % calculate inMask
    inX = inXY(1,:); inX = inX - minX + 1;
    inY = inXY(2,:); inY = inY - minY + 1;
    inMask = poly2mask(inX,inY,DX,DY);

    % calculate gtMask
    gtX = gtXY(1,:); gtX = gtX - minX + 1;
    gtY = gtXY(2,:); gtY = gtY - minY + 1;
    gtMask = poly2mask(gtX,gtY,DX,DY);

    % now calculate a usual maskbased score
    out = ScoreFun(inMask,gtMask);
    

    

