function [states]=build_state_list()
player_sum=2:22;
dealer_card=1:10;
n=1;
for i=1:numel(player_sum)
    for j=1:numel(dealer_card)
        states(n,1)=player_sum(i);
        states(n,2)=dealer_card(j);
        n=n+1;
    end
end
end