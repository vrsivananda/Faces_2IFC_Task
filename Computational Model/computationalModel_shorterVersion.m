close all;
clear;

tic

% Shuffle the rng
rng('shuffle');

% PARAMETERS
nTrials = 5000; % n Trials for each Happy/Fearful
type2NoiseSigmas = 0:0.1:1;
sigma = [0.1,0.1];
muNoise = [0,0];
intensities = 0.01:0.01:1; % Intensities for marginalization start from 0.01 to 1
prior = 0.5; % Prior where chance of getting happy vs fearful is 0.5 for both

% Load the variables from the subject data
load('subject_dPrime_matrix.mat');
load('subject_responsesBasedOnStimuli.mat');

% Set the path to the boundedLine package
addpath('boundedLinePackage/boundedline');
addpath('boundedLinePackage/Inpaint_nans');

% --- Prepare matrices to store data ---

% Inner loop stores
pHsH_posterior_store = nan(nTrials,length(intensities));
pFsH_posterior_store = nan(nTrials,length(intensities));
pFsF_posterior_store = nan(nTrials,length(intensities));
pHsF_posterior_store = nan(nTrials,length(intensities));
pHsN_posterior_store = nan(2*nTrials,length(intensities));
pFsN_posterior_store = nan(2*nTrials,length(intensities));

% Outer loop stores (for i)
percentDiscCorrect_All = nan(length(intensities),length(type2NoiseSigmas));
percentBetTPInterval_All = nan(length(intensities),length(type2NoiseSigmas));
overallLL_All = nan(size(subject_dPrime_matrix,2),length(type2NoiseSigmas));
BIC_All = nan(size(subject_dPrime_matrix,2),length(type2NoiseSigmas));

% Get the number of subjects
nSubjects = size(subject_responsesBasedOnStimuli,4);

% For loop that goes through subjects
for h = 1:nSubjects
    
    % Loop for each Type2 Noise Sigma
    for i = 1:length(type2NoiseSigmas)
        
        currentType2NoiseSigma = type2NoiseSigmas(i);
        
        % For loop for each of the 4 emotion intensities
        for j = 1:size(subject_dPrime_matrix,1)
            
            % Save the rng settings
            scurr = rng;
            
            % Fix the random number generator
            rng(1);
            
            % Get the current subject d'
            currentSubjectDPrime = subject_dPrime_matrix(j,h);
            
            % - Get the emotion level to match -
            
            % If it is > 0, then use divide by 4.5 to get the corresponding
            % emotion level
            if(currentSubjectDPrime > 0)
                % Divide by 4.5 to get the emotion level to simulate (e = d'/4.5)
                simulatedEmotionIntensity = currentSubjectDPrime/4.5;
            % Else match with zero
            else
                simulatedEmotionIntensity = 0;
            end
            % ============= Target Discrimination =============

            % Target Present Interval

            % Get the samples from each distribution
            sampleSH = mvnrnd([0, simulatedEmotionIntensity],sigma,nTrials); % [x,y] for each point from the Happy distribution at this intensity
            sampleSF = mvnrnd([simulatedEmotionIntensity, 0],sigma,nTrials); % [x,y] for each point from the Fearful distribution at this intensity
            
            % Get the likelihoods of each sample being from each distribution/intensity
            % (Marginalization)
            for k = 1:length(intensities)

                % Likelihoods from Happy sample
                lHsH = mvnpdf(sampleSH,[0, intensities(k)],sigma); % likelihood Happy   from Happy sample
                lFsH = mvnpdf(sampleSH,[intensities(k), 0],sigma); % likelihood Fearful from Happy sample

                % Likelihoods from Fearful sample
                lFsF = mvnpdf(sampleSF,[intensities(k), 0],sigma); % likelihood Fearful from Fearful sample
                lHsF = mvnpdf(sampleSF,[0, intensities(k)],sigma); % likelihood Happy   from Fearful sample

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
                pHsH_posterior_store(:,k) = pHsH_posterior;
                pFsH_posterior_store(:,k) = pFsH_posterior;
                pFsF_posterior_store(:,k) = pFsF_posterior;
                pHsF_posterior_store(:,k) = pHsF_posterior;

            end % End of marginalization loop (k)
            
            % Marginalize by averaging the probabilities of all the possible
            % intensities (across the columns)
            pHsH_posterior_average = sum(pHsH_posterior_store,2)/length(intensities);
            pFsH_posterior_average = sum(pFsH_posterior_store,2)/length(intensities);
            pFsF_posterior_average = sum(pFsF_posterior_store,2)/length(intensities);
            pHsF_posterior_average = sum(pHsF_posterior_store,2)/length(intensities);
            
            % Split the posteriors into TP1 and TP2 (target persent interval)
            % - First half goes to TP1 -
            pHsH_posterior_average_TP1 = pHsH_posterior_average(1:(nTrials/2),:);
            pFsH_posterior_average_TP1 = pFsH_posterior_average(1:(nTrials/2),:);
            pFsF_posterior_average_TP1 = pFsF_posterior_average(1:(nTrials/2),:);
            pHsF_posterior_average_TP1 = pHsF_posterior_average(1:(nTrials/2),:);

            % - Second half goes to TP2 -
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
            
            % ============= Interval Betting =============

            % Target Absent Interval

            % Draw the sample from the noise distribution
            sampleN = mvnrnd(muNoise,sigma,2*nTrials);

            % For loop that loops through the intensities to test whether the
            % neutral stimuli would be classified as being from the Happy or
            % Fearful distributions
            % (Marginalization)
            for k = 1:length(intensities)

                % Calculate the likelihoods from each
                lHsN = mvnpdf(sampleN,[0, intensities(k)],sigma); % likelihood Happy   from Noise sample
                lFsN = mvnpdf(sampleN,[intensities(k), 0],sigma); % likelihood Fearful from Noise sample

                % Calculate the posterior probability that the response came from either distribution
                % Happy
                pHsN_posterior = (lHsN*prior)./((lHsN*prior)+(lFsN*prior));
                % Fearful
                pFsN_posterior = (lFsN*prior)./((lHsN*prior)+(lFsN*prior));

                % Log in the posteriors into our store (one column per intensity level)
                pHsN_posterior_store(:,k) = pHsN_posterior;
                pFsN_posterior_store(:,k) = pFsN_posterior;

            end

            % Marginalize by averaging the probabilities of all the possible
            % intensities (across the columns)
            pHsN_posterior_average = sum(pHsN_posterior_store,2)/length(intensities);
            pFsN_posterior_average = sum(pFsN_posterior_store,2)/length(intensities);

            % Get the max posterior (i.e., the posterior of their choice: Happy vs Fearful)
            sN_posterior_average = max(pHsN_posterior_average,pFsN_posterior_average);
        
            % ---------------- Actual Betting ----------------
            
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
            currentLogPosterior = log(respF_stimF_TP1./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respF_stimF_TP1),1]);
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
            currentLogPosterior = log(respH_stimF_TP1./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respH_stimF_TP1),1]);
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
            currentLogPosterior = log(respF_stimH_TP1./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respF_stimH_TP1),1]);
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
            currentLogPosterior = log(respH_stimH_TP1./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respH_stimH_TP1),1]);
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
            currentLogPosterior = log(respF_stimF_TP2./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respF_stimF_TP2),1]);
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
            currentLogPosterior = log(respH_stimF_TP2./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respH_stimF_TP2),1]);
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
            currentLogPosterior = log(respF_stimH_TP2./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respF_stimH_TP2),1]);
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
            currentLogPosterior = log(respH_stimH_TP2./currentNoisePosterior) + normrnd(0,currentType2NoiseSigma,[length(respH_stimH_TP2),1]);
            % Get the logical array where they bet on the correct TP
            currentCorrectBet = currentLogPosterior > 0;
            % Bet on first interval
            bet_int1_respH_stimH_TP2 = sum(currentCorrectBet == 0);
            % Bet on second interval
            bet_int2_respH_stimH_TP2 = sum(currentCorrectBet == 1);

            % ---------- Get the product for this intensity ----------

            % Create a matrix for this intensity
            currentModelIntensityResponses = ...
                [bet_int1_respF_stimF_TP1, bet_int1_respF_stimH_TP1, bet_int1_respF_stimF_TP2, bet_int1_respF_stimH_TP2;...
                 bet_int1_respH_stimF_TP1, bet_int1_respH_stimH_TP1, bet_int1_respH_stimF_TP2, bet_int1_respH_stimH_TP2;...
                 bet_int2_respF_stimF_TP1, bet_int2_respF_stimH_TP1, bet_int2_respF_stimF_TP2, bet_int2_respF_stimH_TP2;...
                 bet_int2_respH_stimF_TP1, bet_int2_respH_stimH_TP1, bet_int2_respH_stimF_TP2, bet_int2_respH_stimH_TP2];
            
            % Convert into probabilities
            currentModelIntensityResponsesProbabilities = currentModelIntensityResponses./sum(sum(currentModelIntensityResponses));
             
            % Get the subject grid for this intensity
            currentSubjectInstensityResponses = subject_responsesBasedOnStimuli(:,:,j,h);
            
            % Raise to the power of the subject responses and get their
            % product
            product_currentSubjectIntensity(j) = prod(prod(currentModelIntensityResponsesProbabilities.^currentSubjectInstensityResponses));
            
            % Restore rng
            rng(scurr.Seed, scurr.Type);
            
        end % End of loop for each emotion intensity (j)
        
        % Calculate the log likelihood for this subject for this emotion
        % level
        currentSubjectT2Noise_LL = log(prod(product_currentSubjectIntensity));
        
        % Store that into our LL store
        overallLL_All(h,i) = currentSubjectT2Noise_LL;
        
    end % End of loop that goes through Type2NoiseSigmas (i)
    
end % End of h = 1:nSubjects

% ======== t-test ========
firstLL_All = overallLL_All(:,1);
lastLL_All = overallLL_All(:,end);

[h,p,ci,stats] = ttest(firstLL_All, lastLL_All);

% ======== PLOTTING ========
 
figure;

% Plot the lines for each subject level
for i = 1:size(overallLL_All,1)
    hold on;
    plot(type2NoiseSigmas', overallLL_All(i,:));
    %legendInfo{h} = ['subject = ' num2str(noiseSigmas(h))];
end
%legend(legendInfo,'Location','NorthWest');
xlim([min(type2NoiseSigmas) max(type2NoiseSigmas)]);
ylim([min(min(overallLL_All))-1, max(max(overallLL_All))+1]);
xlabel('Type 2 noise level (\sigma)');
ylabel('L_{m}(\phi|data)');

% Plot the graph
figure;
h1 = boundedline(type2NoiseSigmas', mean(overallLL_All),std(overallLL_All)./sqrt(nSubjects),'alpha','cmap',[0 0 0]);
set(h1, 'lineWidth', 4);
xlim([min(type2NoiseSigmas) max(type2NoiseSigmas)]);
ylim([-308, -302]);
xlabel('Type 2 noise level (\sigma)');
ylabel('L_{m}(\phi|data)');


toc