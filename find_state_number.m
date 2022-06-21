function [num_state]=find_state_number(states,player_sum,dealer_showing_card)
state=[player_sum dealer_showing_card];
for i=1:size(states,1)
    if states(i,:)==state
        num_state=i;
    end
end
    