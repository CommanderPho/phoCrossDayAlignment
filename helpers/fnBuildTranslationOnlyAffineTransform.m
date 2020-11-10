function [tform] = fnBuildTranslationOnlyAffineTransform(xoffSet, yoffSet)
%FNBUILDTRANSLATIONONLYAFFINETRANSFORM Returns the 2d affine transform
%given the x and y translation offsets.
%   Build translation-only affine2d transform:
    T = [1 0 0; 0 1 0; xoffSet yoffSet 1];
    tform = affine2d(T);
end

