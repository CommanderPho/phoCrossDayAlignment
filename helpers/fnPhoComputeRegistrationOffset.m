function [offset_first_to_second, debugStructures] = fnPhoComputeRegistrationOffset(first_day_frame, second_day_frame)
%FNPHOCOMPUTEREGISTRATIONOFFSET Given two registered images, compute the
%offset required to produce the second from the first.
%   Detailed explanation goes here

croOptions.showDebugPlots = false;

croOptions.computationMethod = 'normxcorr';
% croOptions.computationMethod = 'freqDomainMult';
% croOptions.computationMethod = 'directConvolution';

first.time = first_day_frame;
second.time = second_day_frame;


%%Normalized Cross Correlation Method
if strcmp(croOptions.computationMethod, 'normxcorr')
    crossCorrelation = normxcorr2(first.time, second.time);
    if croOptions.showDebugPlots
        figure;
        surf(crossCorrelation)
        shading flat
    end

    [ypeak, xpeak] = find(crossCorrelation==max(crossCorrelation(:)));
    yoffSet = ypeak - size(first.time, 1);
    xoffSet = xpeak - size(first.time, 2);
%     % Build translation-only affine2d transform:
%     T = [1 0 0; 0 1 0; -xoffSet -yoffSet 1];
%     tform = affine2d(T);
    [tform] = fnBuildTranslationOnlyAffineTransform(-xoffSet, -yoffSet);
    offset_first_to_second = [-xoffSet -yoffSet];
    
    debugStructures.crossCorrelation = crossCorrelation;
    debugStructures.tform = tform;
    
elseif strcmp(croOptions.computationMethod, 'freqDomainMult')
    % Frequency Domain Multiplication Method:
    % Convert to the frequency domain
    first.freq = fft(first.time);
    second.freq = fft(second.time);
    % Multiply in the frequency domain
    convolvedProduct.freq = first.freq .* second.freq;
    % Compute the inverse FFT 
    convolvedProduct.time = ifft(convolvedProduct.freq);
    
    % [convolvedProduct.maxValue,convolvedProduct.maxLinearIndex] = max(convolvedProduct.time,[],'all','linear'); % Find maximum
    % [convolvedProduct.indexI, convolvedProduct.indexJ] = ind2sub(size(convolvedProduct.time), convolvedProduct.maxLinearIndex); % Convert linear index to offset
    % convolvedProduct.maxIndex = [convolvedProduct.indexI, convolvedProduct.indexJ];
    
    error('Unfinished implementation!')
    
elseif strcmp(croOptions.computationMethod, 'directConvolution')
    % Direct Convolution Method:
    convolvedProduct.time = conv2(first.time, second.time,'same');

    convolvedProduct.maxValue = max(convolvedProduct.time,[],'all'); % Find maximum value
    convolvedProduct.maxIndex = find(convolvedProduct.time == convolvedProduct.maxValue);

    % [convolvedProduct.maxValue,convolvedProduct.maxLinearIndex] = max(convolvedProduct.time,[],'all','linear'); % Find maximum
    % [convolvedProduct.indexI, convolvedProduct.indexJ] = ind2sub(size(convolvedProduct.time), convolvedProduct.maxLinearIndex); % Convert linear index to offset
    % convolvedProduct.maxIndex = [convolvedProduct.indexI, convolvedProduct.indexJ];

    if croOptions.showDebugPlots
        figure(1)
        [h] = fnPhoMatrixPlot(convolvedProduct.time);
        % hold on;
        % plot(convolvedProduct.indexI, convolvedProduct.indexJ,'k');
    end

    % offset_first_to_second = [0.0, 0.0];
    offset_first_to_second = convolvedProduct.maxIndex;
    debugStructures.convolvedProduct = convolvedProduct;

else
    error('undefined method!')
end








end

