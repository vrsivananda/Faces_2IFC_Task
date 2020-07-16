function plotDetectionVsDiscriminationData(type1SDTDetectionDataAll, type1SDTDiscriminationDataAll)

% Smoothing parameters
smoothingParameter = 0.99;

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% Shade of gray
grayIndex = 0.5;

% Filter out only the d' data
detectionDPrimes = squeeze(type1SDTDetectionDataAll(1,:,:))';
discriminationDPrimes = squeeze(type1SDTDiscriminationDataAll(1,:,:))';
% ^ After squeezing, rows = subjects, col = d' for intenstities

detectionDPrimesMean = mean(detectionDPrimes,2);
discriminationDPrimesMean = mean(discriminationDPrimes,2);

figure;
%subplot(1,3,2)
hold on;
fitObject = fit(discriminationDPrimes(:)./sqrt(2),detectionDPrimes(:),'smoothingspline','SmoothingParam',smoothingParameter);
h1 = plot(fitObject, discriminationDPrimes(:)./sqrt(2),detectionDPrimes(:));
%h1 = plot(discriminationDPrimes./sqrt(2),detectionDPrimes, 'k.','linestyle', 'none');
set(h1,'color','k');
set(h1,'lineWidth',4);
set(h1,'markerSize',25);
set(h1,'markerEdgeColor',[grayIndex, grayIndex, grayIndex]);
set(h1,'markerFaceColor',[grayIndex, grayIndex, grayIndex]);
plot([-0.5,1.5],[-1.5,2.5],'k--');
xlabel('Emotion discrimination d'' / sqrt(2)');
ylabel('d'' for betting on emotion-present interval');
% Turn off the legend
legendOff = gca; legend(legendOff,'off');


x = 0;