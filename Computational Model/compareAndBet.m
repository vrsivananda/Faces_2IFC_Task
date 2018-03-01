function [permCounter, betTP_counter, betTA_respF_counter, betTA_respH_counter] = ...
		compareAndBet(TP_array, respF_stimN, respH_stimN, permCounter, permutation,...
		betTP_counter, betTA_respF_counter, betTA_respH_counter)
	
	% For loop that goes through the particular TP array and pair the posteriors up
	% with the appropriate posterior from the TA array
	for i = 1:length(TP_array)
		
		% Increment the counter
		permCounter = permCounter + 1;
		
		% Check if the index is within the length of the respH_stimN array
		% If it is smaller, then we use the respH_stimN array
		if(permutation(permCounter) <= length(respH_stimN))
			
			% Check if the TP or TA interval has a larger posterior
			TP_is_larger = TP_array(i) > respH_stimN(permutation(permCounter));
			
			% If it is larger, then we bet on the TP interval
			if(TP_is_larger)
				betTP_counter = betTP_counter + 1;
			% Else TP is smaller, so we bet on the TA interval (for the
			% happy response)
			else
				betTA_respH_counter = betTA_respH_counter + 1;
			end
		
		% Else the index is outside the length of the respH_stimN array, so
		% we use the respF_stimN array instead
		else
			
			% Check if the TP or TA interval has a larger posterior
			TP_is_larger = TP_array(i) > respF_stimN(permutation(permCounter) - length(respH_stimN));
			
			% If it is larger, then we bet on the TP interval
			if(TP_is_larger)
				betTP_counter = betTP_counter + 1;
			% Else TP is smaller, so we bet on the TA interval (for the
			% fearful response)
			else
				betTA_respF_counter = betTA_respF_counter + 1;
			end
			
		end % End of outside if
		
	end % End of for loop for respH_stimH_TP1
	
	%output = [permCounter, betTP_counter, betTA_respH_counter, betTA_respF_counter];
	
end % End of function