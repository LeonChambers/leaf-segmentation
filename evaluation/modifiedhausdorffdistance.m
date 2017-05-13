function mhd = modifiedhausdorffdistance(arMask, gtMask)
%MODIFIEDHAUSDORFFDISTANCE Computes the Modified Hausdorff Distance (MHD)
% between the contours of algorithmic result and ground truth segmentation
% masks. Originally proposed in [1]. For further details see [1] and [2].
%
% Disclaimer: implementation of the Modified Hausdorff Distance, available
% on File Exchange at MATLAB Central, is courtesy of B S SasiKanth, Indian
% Institute of Technology Guwahati.
%
% [1] M.-P. Dubuisson, A.K. Jain, "A modified Hausdorff distance for object
%     matching," in 12th IAPR International Conference on Pattern Recognition,
%     pp. 566-568, Oct. 1994.
% [2] M. Minervini, A. Fischbach, H. Scharr, S.A. Tsaftaris, "Finely-grained
%     annotated datasets for image-based plant phenotyping," Pattern Recognition
%     Letters, 2015.
%
% Input:
%    arMask - Algorithmic result binary segmentation mask, same size of gtMask.
%    gtMask - Ground truth binary segmentation mask, same size of arMask.
%
% Output:
%       mhd - Modified Hausdorff Distance.
%
% Example usage:
%    arMask = rand(24,32) > 0.5;
%    gtMask = rand(24,32) > 0.5;
%    mhd = modifiedhausdorffdistance(arMask, gtMask);
%
% Author:  Massimo Minervini
% Contact: massimo.minervini@imtlucca.it
% Version: 1.0
% Date:    07/01/2016
%
% Copyright (C) 2016 Pattern Recognition and Image Analysis (PRIAn) Unit,
% IMT Institute for Advanced Studies, Lucca, Italy.
% All rights reserved.

assert(isequal(size(arMask),size(gtMask)),'Segmentation masks must be of the same size.')
% ensure masks are binary
arMask = logical(arMask);
gtMask = logical(gtMask);

nPointsArMask = nnz(arMask);
nPointsGtMask = nnz(gtMask);
if nPointsArMask == 0 && nPointsGtMask == 0
    mhd = 0; % the empty set is at distance 0 from itself
elseif nPointsArMask == 0 || nPointsGtMask == 0
    mhd = Inf; % distance between empty set and any nonempty set is Inf
else
    contourArMask = bwboundaries(arMask,'noholes');
    contourArMask = vertcat(contourArMask{:});
    contourGtMask = bwboundaries(gtMask,'noholes');
    contourGtMask = vertcat(contourGtMask{:});
    if exist('ModHausdorffDistMex','file')
        mhd = ModHausdorffDistMex(contourArMask,contourGtMask);
    else
        warning('Using "ModHausdorffDist.m". To speed-up execution run "mex ModHausdorffDistMex.cpp" to compile the MEX-file.')
        mhd = ModHausdorffDist(contourArMask,contourGtMask);
    end
end

end
