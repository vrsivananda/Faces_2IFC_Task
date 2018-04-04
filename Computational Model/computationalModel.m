close all;
clear;

tic

nTrials = 5000; % n Trials for each Happy/Fearful
intensities = 0.01:0.01:1; % Intensities for targets start from 0.01 to 1
theta = pi/2; % The angle between H and F distributions
muNoise = [0,0];
muSignalH = [cos(theta),sin(theta)];
muSignalF = [1,0];
sigma = [0.1,0.1];
type2NoiseSigmas = 0:0.1:0; % Gaussian noise to be added to interval betting
prior = 0.5; % Prior where chance of getting happy vs fearful is 0.5 for both

% Load the variables from the subject data
load('subject_dPrime_matrix.mat');
load('subject_responsesBasedOnStimuli.mat');

% --- Prepare matrices to store data ---

% Inner loop stores
pHsH_posterior_store = nan(nTrials,length(intensities));
pFsH_posterior_store = nan(nTrials,length(intensities));
pFsF_posterior_store = nan(nTrials,length(intensities));
pHsF_posterior_store = nan(nTrials,length(intensities));
pHsN_posterior_store = nan(2*nTrials,length(intensities));
pFsN_posterior_store = nan(2*nTrials,length(intensities));

% Middle loop stores (for j)
percentDiscCorrect_currentNoise   = nan(length(intensities),1);
percentBetTPInterval_currentNoise = nan(length(intensities),1);

% Outer loop stores (for h)
percentDiscCorrect_All = nan(length(intensities),length(type2NoiseSigmas));
percentBetTPInterval_All = nan(length(intensities),length(type2NoiseSigmas));
overallProbability_All = nan(size(subject_dPrime_matrix,2),length(type2NoiseSigmas));
BIC_All = nan(size(subject_dPrime_matrix,2),length(type2NoiseSigmas));

% Store for the responses based on stimuli
compModel_responsesBasedOnStimuli = nan(4, 4, length(intensities));
% ^ This is a (4 x 4 x length(intensities)) dimensional matrix

% For loop that loops through the noise levels
for h = 1:length(type2NoiseSigmas)
    
    % Load in the current sigma
    currentType2NoiseSigma = type2NoiseSigmas(h);

    % For loop that loops through the intensities
    for j = 1:length(intensities)

        % ============= Target Discrimination =============

        % Target Present Interval

        % Get the samples from each distribution
        sampleSH = mvnrnd(muSignalH.*intensities(j),sigma,nTrials); % [x,y] for each point from the Happy distribution at this intensity
        sampleSF = mvnrnd(muSignalF.*intensities(j),sigma,nTrials); % [x,y] for each point from the Fearful distribution at this intensity

        % Get the likelihoods of each sample being from each distribution/intensity
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

            % Log the posteriors for all the intensities (add each of them in as a column of nTrials in
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

        % Indices of those which are correct
        % (Because the subject will decide based on which posterior is higher,
        % and those decisions are correct if the sample also came from a 
        % corresponding distribution)
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
        percentDiscCorrect_currentNoise(j) = percentDiscCorrect;

        % vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
        % To classify the responses based on stimuli

        % Split the posteriors into TP1 and TP2 (target persent interval)
        % First half goes to TP1
        pHsH_posterior_average_TP1 = pHsH_posterior_average(1:(nTrials/2),:);
        pFsH_posterior_average_TP1 = pFsH_posterior_average(1:(nTrials/2),:);
        pFsF_posterior_average_TP1 = pFsF_posterior_average(1:(nTrials/2),:);
        pHsF_posterior_average_TP1 = pHsF_posterior_average(1:(nTrials/2),:);

        % Second half goes to TP2
        pHsH_posterior_average_TP2 = pHsH_posterior_average(((nTrials/2)+1):nTrials,:);
        pFsH_posterior_average_TP2 = pFsH_posterior_average(((nTrials/2)+1):nTrials,:);
        pFsF_posterior_average_TP2 = pFsF_posterior_average(((nTrials/2)+1):nTrials,:);
        pHsF_posterior_average_TP2 = pHsF_posterior_average(((nTrials/2)+1):nTrials,:);

        % Get the posteriors of trials where subjects respond:
        % - TP1 - 
        % (1) Happy when stimuli is Happy
        respH_stimH_TP1 = pHsH_posterior_average_TP1(pHsH_posterior_average_TP1 > pFsH_posterior_average_TP1);
        % (2) Fearful when stimuli is Happy
        respF_stimH_TP1 = pFsH_posterior_average_TP1(pFsH_posterior_average_TP1 > pHsH_posterior_average_TP1);
        % (3) Fearful when stimuli is Fearful
        respF_stimF_TP1 = pFsF_posterior_average_TP1(pFsF_posterior_average_TP1 > pHsF_posterior_average_TP1);
        % (4) Happy when stimuli is Fearful
        respH_stimF_TP1 = pHsF_posterior_average_TP1(pHsF_posterior_average_TP1 > pFsF_posterior_average_TP1);

        % - TP2 - 
        % (1) Happy when stimuli is Happy
        respH_stimH_TP2 = pHsH_posterior_average_TP2(pHsH_posterior_average_TP2 > pFsH_posterior_average_TP2);
        % (2) Fearful when stimuli is Happy
        respF_stimH_TP2 = pFsH_posterior_average_TP2(pFsH_posterior_average_TP2 > pHsH_posterior_average_TP2);
        % (3) Fearful when stimuli is Fearful
        respF_stimF_TP2 = pFsF_posterior_average_TP2(pFsF_posterior_average_TP2 > pHsF_posterior_average_TP2);
        % (4) Happy when stimuli is Fearful
        respH_stimF_TP2 = pHsF_posterior_average_TP2(pHsF_posterior_average_TP2 > pFsF_posterior_average_TP2);

        % ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


        % ============= Interval Betting =============

        % Get the larger value of posteriors for each happy/fearful distribution
        %sH_posterior_average = max(pHsH_posterior_average,pFsH_posterior_average);
        %sF_posterior_average = max(pFsF_posterior_average,pHsF_posterior_average);

        % Target Absent Interval

        % Draw the sample from the noise distribution
        sampleN = mvnrnd(muNoise,sigma,2*nTrials);

        % For loop that loops through the intensities to test whether the
        % neutral stimuli would be classified as being from the Happy or
        % Fearful distributions
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

        % -- Actual Betting --

        % vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

        % To classify the responses based on stimuli

        % ------------- Fit them into boxes -------------

        % Boxes are in the form:
        %     | F,N | H,N | N,F | N,H | <-- Columns: Stimuli
        % ----|-----|-----|-----|-----|
        % F,x |     |     |     |     |
        % ----|-----|-----|-----|-----|
        % H,x |     |     |     |     |
        % ----|-----|-----|-----|-----|
        % x,F |     |     |     |     |
        % ----|-----|-----|-----|-----|
        % x,H |     |     |     |     |
        % ----+-----+-----+-----+-----+
        % 
        % ^ Rows: Responses 

        % ---------- TP1 ----------


        % --- Variables to keep track of betting ---

        % Bets when fearful face on interval 1 (TP = 1, Fear)
        bet_int1_respF_stimF_TP1 = 0;
        bet_int1_respH_stimF_TP1 = 0;
        bet_int2_respF_stimF_TP1 = 0;
        bet_int2_respH_stimF_TP1 = 0;

        % Bets when happy face on interval 1 (TP = 1, Happy)
        bet_int1_respF_stimH_TP1 = 0;
        bet_int1_respH_stimH_TP1 = 0;
        bet_int2_respF_stimH_TP1 = 0;
        bet_int2_respH_stimH_TP1 = 0;

        % ------- Compare against noise -------

        % Counter to keep track of where we are in the noise posteriors (the sN_posterior_average)
        sN_counter = 0;

        % -- response F stimulus F --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respF_stimF_TP1)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respF_stimF_TP1);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respF_stimF_TP1./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respF_stimF_TP1),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respF_stimF_TP1 = sum(currentCorrectBet == 1);
        % Bet on second interval
        bet_int2_respF_stimF_TP1 = sum(currentCorrectBet == 0);


        % -- response H stimulus F --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respH_stimF_TP1)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respH_stimF_TP1);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respH_stimF_TP1./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respH_stimF_TP1),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respH_stimF_TP1 = sum(currentCorrectBet == 1);
        % Bet on second interval
        bet_int2_respH_stimF_TP1 = sum(currentCorrectBet == 0);


        % -- response F stimulus H --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respF_stimH_TP1)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respF_stimH_TP1);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respF_stimH_TP1./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respF_stimH_TP1),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respF_stimH_TP1 = sum(currentCorrectBet == 1);
        % Bet on second interval
        bet_int2_respF_stimH_TP1 = sum(currentCorrectBet == 0);


        % -- response H stimulus H --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respH_stimH_TP1)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respH_stimH_TP1);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respH_stimH_TP1./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respH_stimH_TP1),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respH_stimH_TP1 = sum(currentCorrectBet == 1);
        % Bet on second interval
        bet_int2_respH_stimH_TP1 = sum(currentCorrectBet == 0);


        % ---------- TP2 ----------


        % --- Variables to keep track of betting ---

        % Bets when fearful face on interval 1 (TP = 2, Fear)
        bet_int1_respF_stimF_TP2 = 0;
        bet_int1_respH_stimF_TP2 = 0;
        bet_int2_respF_stimF_TP2 = 0;
        bet_int2_respH_stimF_TP2 = 0;

        % Bets when happy face on interval 1 (TP = 2, Happy)
        bet_int1_respF_stimH_TP2 = 0;
        bet_int1_respH_stimH_TP2 = 0;
        bet_int2_respF_stimH_TP2 = 0;
        bet_int2_respH_stimH_TP2 = 0;

        % ------- Compare against noise -------

        % -- response F stimulus F --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respF_stimF_TP2)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respF_stimF_TP2);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respF_stimF_TP2./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respF_stimF_TP2),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respF_stimF_TP2 = sum(currentCorrectBet == 0);
        % Bet on second interval
        bet_int2_respF_stimF_TP2 = sum(currentCorrectBet == 1);



        % -- response H stimulus F --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respH_stimF_TP2)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respH_stimF_TP2);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respH_stimF_TP2./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respH_stimF_TP2),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respH_stimF_TP2 = sum(currentCorrectBet == 0);
        % Bet on second interval
        bet_int2_respH_stimF_TP2 = sum(currentCorrectBet == 1);


        % -- response F stimulus H --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respF_stimH_TP2)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respF_stimH_TP2);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respF_stimH_TP2./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respF_stimH_TP2),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respF_stimH_TP2 = sum(currentCorrectBet == 0);
        % Bet on second interval
        bet_int2_respF_stimH_TP2 = sum(currentCorrectBet == 1);


        % -- response H stimulus H --
        % Get the current noise posteriors to compare for interval betting
        currentNoisePosterior = sN_posterior_average((sN_counter+1):(sN_counter + length(respH_stimH_TP2)));
        % Increment the sN counter
        sN_counter = sN_counter + length(respH_stimH_TP2);
        % Get the log of this posterior against the noise distribution, with
        % some Gaussian noise added
        currentLogPosterior = log(respH_stimH_TP2./currentNoisePosterior) + normrnd(0,currentNoiseSigma,[length(respH_stimH_TP2),1]);
        % Get the logical array where they bet on the correct TP
        currentCorrectBet = currentLogPosterior > 0;
        % Bet on first interval
        bet_int1_respH_stimH_TP2 = sum(currentCorrectBet == 0);
        % Bet on second interval
        bet_int2_respH_stimH_TP2 = sum(currentCorrectBet == 1);


        % ---------- Store it into our responsesBasedOnStimuli store ----------

        % Create a matrix for this intensity
        currentIntensityResponses = ...
            [bet_int1_respF_stimF_TP1, bet_int1_respF_stimH_TP1, bet_int1_respF_stimF_TP2, bet_int1_respF_stimH_TP2;...
             bet_int1_respH_stimF_TP1, bet_int1_respH_stimH_TP1, bet_int1_respH_stimF_TP2, bet_int1_respH_stimH_TP2;...
             bet_int2_respF_stimF_TP1, bet_int2_respF_stimH_TP1, bet_int2_respF_stimF_TP2, bet_int2_respF_stimH_TP2;...
             bet_int2_respH_stimF_TP1, bet_int2_respH_stimH_TP1, bet_int2_respH_stimF_TP2, bet_int2_respH_stimH_TP2];

        % Insert it into the responsesBasedOnStimuli store
        compModel_responsesBasedOnStimuli(:,:,j) = currentIntensityResponses;


        % ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

        % They bet on the target present interval when the posterior of the target
        % present interval > posterior of target absent interval
        %betTPIndices = log_posterior_average_comparisons > 0;

        % Number of bets on TP Interval
        %nBetTP = sum(betTPIndices);
        nBetTP = bet_int1_respF_stimF_TP1 + ...
                 bet_int1_respF_stimH_TP1 + ...
                 bet_int1_respH_stimF_TP1 + ...
                 bet_int1_respH_stimH_TP1 + ...
                 bet_int2_respF_stimF_TP2 + ...
                 bet_int2_respF_stimH_TP2 + ...
                 bet_int2_respH_stimF_TP2 + ...
                 bet_int2_respH_stimH_TP2;

        % Percent that bet on the target present interval
        percentBetTPInterval = nBetTP/(2*nTrials);

        % Insert that percentage into the store to keep track
        percentBetTPInterval_currentNoise(j) = percentBetTPInterval;

    end % End of for j = 1:length(intensities)

    % vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

    % Calculate the d's for all the intensities
    dPrime_array = calculateDPrimeArray(compModel_responsesBasedOnStimuli);
    
    %----plot the dPrime_array against the intensities----
    figure;
    plot(intensities',dPrime_array./intensities');
    ylabel('d''/e');
    xlabel('e');
    xlim([0,max(intensities)]);
    
    %-----------------------------------------------------

    % Find the matching dPrime
    matchingDPrimeIndex = matchDPrime(subject_dPrime_matrix, dPrime_array);

    % Calculate the Overall Probability
    overallProbability = calculateOverallProbability(compModel_responsesBasedOnStimuli, subject_responsesBasedOnStimuli, matchingDPrimeIndex);
    
    % Determine the k parameter for BIC
    if(currentNoiseSigma == 0)
        BIC_k_parameter = 0;
    else
        BIC_k_parameter = 1;
    end
    
    % Calulate BIC
    BIC = (log(2*nTrials)*BIC_k_parameter) - (2*log(overallProbability));
    
    % ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    % Store data
    percentDiscCorrect_All(:,h) = percentDiscCorrect_currentNoise;
    percentBetTPInterval_All(:,h) = percentBetTPInterval_currentNoise;
    overallProbability_All(:,h) = overallProbability;
    BIC_All(:,h) = BIC;

end % End of for h = noiseSigmas
    
% Dashed lines parameters
lineWidth = 0.5;
lineStyle = '--';


% ==================== PLOT 1 ====================

% --- Draw the graph ---
figure;
% Plot the lines for each noise level
for h = 1:length(type2NoiseSigmas)
    hold on;
    plot(percentDiscCorrect_All(:,h), percentBetTPInterval_All(:,h));
    legendInfo{h} = ['noiseSigma = ' num2str(type2NoiseSigmas(h))];
end
legend(legendInfo,'Location','NorthWest');
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


% ==================== PLOT 2 ====================

figure;

% Plot the lines for each subject level
for i = 1:size(overallProbability_All,1)
    hold on;
    plot(type2NoiseSigmas', overallProbability_All(i,:));
    %legendInfo{h} = ['subject = ' num2str(noiseSigmas(h))];
end
%legend(legendInfo,'Location','NorthWest');
xlim([min(type2NoiseSigmas) max(type2NoiseSigmas)]);
%ylim([0 1]);
xlabel('Type2 Noise Level');
ylabel('Log Likelihood');

% ==================== PLOT 3 ====================

% --- Simple schematic for all the points on the 2D SDT space
figure;
scatter(sampleSH(:,1),sampleSH(:,2));
hold on;
scatter(sampleSF(:,1),sampleSF(:,2));
hold on;
scatter(sampleN(:,1),sampleN(:,2));
xlim([-1 2]);
ylim([-1 2]);


toc
