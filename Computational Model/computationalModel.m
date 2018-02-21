close all;
clear;

nTrials = 5000; % n Trials for each Happy/Fearful
intensities = 0.01:0.01:1; % Intensities for targets start from 0.1 to 1
muNoise = [0,0];
muSignalH = [0,1];
muSignalF = [1,0];
sigma = [0.1,0.1];
prior = 0.5; % Prior where chance of getting happy vs fearful is 0.5 for both

% --- Prepare matrices to store data ---

% Inner loop stores
pHsH_posterior_store = nan(nTrials,length(intensities));
pFsH_posterior_store = nan(nTrials,length(intensities));
pFsF_posterior_store = nan(nTrials,length(intensities));
pHsF_posterior_store = nan(nTrials,length(intensities));
pHsN_posterior_store = nan(2*nTrials,length(intensities));
pFsN_posterior_store = nan(2*nTrials,length(intensities));

% Outer loop stores
percentDiscCorrect_All   = nan(length(intensities),1);
percentBetTPInterval_All = nan(length(intensities),1);


for j = 1:length(intensities)

    % ----- Target Discrimination -----

    % Target Present Interval

    % Get the samples from each distribution
    sampleSH = mvnrnd([0, intensities(j)],sigma,nTrials);
    sampleSF = mvnrnd([intensities(j), 0],sigma,nTrials);

    % Get the likelihoods of each sample being from each distribution
    for i = 1:length(intensities)

        % Likelihoods from Happy sample
        lHsH = mvnpdf(sampleSH,[0, intensities(i)],sigma); % likelihood Happy   from Happy sample
        lFsH = mvnpdf(sampleSH,[intensities(i), 0],sigma); % likelihood Fearful from Happy sample

        % Likelihoods from Fearful sample
        lFsF = mvnpdf(sampleSF,[intensities(i), 0],sigma); % likelihood Fearful from Fearful sample
        lHsF = mvnpdf(sampleSF,[0, intensities(i)],sigma); % likelihood Happy   from Fearful sample

        % Calculate the posterior probability that the responses came from the
        % each of the target present distributions
        % Happy distribution
        pHsH_posterior = (lHsH*prior)./((lHsH*prior)+(lFsH*prior));
        pFsH_posterior = (lFsH*prior)./((lHsH*prior)+(lFsH*prior));
        % Fearful distribution
        pFsF_posterior = (lFsF*prior)./((lFsF*prior)+(lHsF*prior));
        pHsF_posterior = (lHsF*prior)./((lFsF*prior)+(lHsF*prior));

        % Log the posteriors for all the intensities (add each of them in as a column in
        % our store)
        pHsH_posterior_store(:,i) = pHsH_posterior;
        pFsH_posterior_store(:,i) = pFsH_posterior;
        pFsF_posterior_store(:,i) = pFsF_posterior;
        pHsF_posterior_store(:,i) = pHsF_posterior;

    end

    % Marginalize by averaging the probabilities of all the possible
    % intensities (across the columns)
    pHsH_posterior_average = sum(pHsH_posterior_store,2)/length(intensities);
    pFsH_posterior_average = sum(pFsH_posterior_store,2)/length(intensities);
    pFsF_posterior_average = sum(pFsF_posterior_store,2)/length(intensities);
    pHsF_posterior_average = sum(pHsF_posterior_store,2)/length(intensities);

    %Indices of those which are correct
    indexCorrectH = pHsH_posterior_average > pFsH_posterior_average;
    indexCorrectF = pFsF_posterior_average > pHsF_posterior_average;

    % Number correct from each sample
    nCorrectH = sum(indexCorrectH);
    nCorrectF = sum(indexCorrectF);
    % Combine them
    nDiscCorrect = nCorrectH + nCorrectF;
    % Calculate percentage correct for discrimination
    percentDiscCorrect = nDiscCorrect/(2*nTrials);

    % Insert into the array to store
    percentDiscCorrect_All(j) = percentDiscCorrect;

    % ----- Interval Betting -----

    % Get the larger value of posteriors for each happy/fearful distribution
    sH_posterior_average = max(pHsH_posterior_average,pFsH_posterior_average);
    sF_posterior_average = max(pFsF_posterior_average,pHsF_posterior_average);

    % Target Absent Interval

    % Draw the sample from the noise distribution
    sampleN = mvnrnd(muNoise,sigma,2*nTrials);

    for i = 1:length(intensities)

        % Calculate the likelihoods from each
        lHsN = mvnpdf(sampleN,[0, intensities(i)],sigma); % likelihood Happy   from Noise sample
        lFsN = mvnpdf(sampleN,[intensities(i), 0],sigma); % likelihood Fearful from Noise sample

        % Calculate the posterior probability that the response came from either distribution
        % Happy
        pHsN_posterior = (lHsN*prior)./((lHsN*prior)+(lFsN*prior));
        % Fearful
        pFsN_posterior = (lFsN*prior)./((lHsN*prior)+(lFsN*prior));

        % Log in the posteriors into our store (one column per intensity level)
        pHsN_posterior_store(:,i) = pHsN_posterior;
        pFsN_posterior_store(:,i) = pFsN_posterior;

    end

    % Marginalize by averaging the probabilities of all the possible
    % intensities (across the columns)
    pHsN_posterior_average = sum(pHsN_posterior_store,2)/length(intensities);
    pFsN_posterior_average = sum(pFsN_posterior_store,2)/length(intensities);

    % Get the max posterior (i.e., the posterior of their choice: Happy vs Fearful)
    sN_posterior_average = max(pHsN_posterior_average,pFsN_posterior_average);

    % They bet on the target present interval when the posterior of the target
    % present interval > posterior of target absent interval
    betTPIndices = [sH_posterior_average; sF_posterior_average] > sN_posterior_average;

    % Number of bets on TP Interval
    nBetTP = sum(betTPIndices);

    % Percent that bet on the target present interval
    percentBetTPInterval = nBetTP/(2*nTrials);

    % Insert that percentage into the store to keep track
    percentBetTPInterval_All(j) = percentBetTPInterval;


end % End of for j = 1:length(intensities)

% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';

% --- Draw the graph ---
figure;
plot(percentDiscCorrect_All, percentBetTPInterval_All);
xlim([0 1]);
ylim([0 1]);
xlabel('Target discrimination % correct');
ylabel('% bet on target-present interval');

% --- Draw the lines on the graph ---

% line for when y = 0.5
hold on;
plot([0, 1], [0.5, 0.5],'LineStyle',lineStyle,'LineWidth',lineWidth);

% line for when x = 0.5
hold on;
plot([0.5, 0.5], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth);

% line for when x = y
hold on;
plot([0, 1], [0, 1],'LineStyle',lineStyle,'LineWidth',lineWidth);

% --- Simple schematic for all the points on the 2D SDT space
figure;
scatter(sampleSH(:,1),sampleSH(:,2));
hold on;
scatter(sampleSF(:,1),sampleSF(:,2));
hold on;
scatter(sampleN(:,1),sampleN(:,2));

