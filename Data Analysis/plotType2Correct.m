function plotType2Correct(betTPIntervalDataAll)

    % Get the % correct for each intensity
    pCorrect_5percent = permute(betTPIntervalDataAll(1,1,:), [3,2,1]);
    pCorrect_15percent = permute(betTPIntervalDataAll(1,2,:), [3,2,1]);
    pCorrect_25percent = permute(betTPIntervalDataAll(1,3,:), [3,2,1]);
    pCorrect_75percent = permute(betTPIntervalDataAll(1,4,:), [3,2,1]);
    
    % Get the means
    mean_5percent = mean(pCorrect_5percent);
    mean_15percent = mean(pCorrect_15percent);
    mean_25percent = mean(pCorrect_25percent);
    mean_75percent = mean(pCorrect_75percent);
    
    % Get the SD
    sd__5percent = std(pCorrect_5percent);
    sd__15percent = std(pCorrect_15percent);
    sd__25percent = std(pCorrect_25percent);
    sd__75percent = std(pCorrect_75percent);
    
    % Calculate the SEM
    sem_5percent = sd__5percent/sqrt(length(pCorrect_5percent));
    sem_15percent = sd__15percent/sqrt(length(pCorrect_15percent));
    sem_25percent = sd__25percent/sqrt(length(pCorrect_25percent));
    sem_75percent = sd__75percent/sqrt(length(pCorrect_75percent));
    
    

end % End of function