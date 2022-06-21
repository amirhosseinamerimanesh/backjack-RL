clear all
close all
clc
%RL_initialization
states=build_state_list();
extra_action1 = [1;2] ;                                                       % extra_action1 ==> 1 = make ace,11;2= make ace,1
extra_action2 = [1;2] ;                                                       % extra_action2 ==> 1 = make same cards split to two , 2 = dont split them
actions=[1;2];                                                                % actions ==> 1=hit;2=stick;
Q=zeros(size(states,1),size(actions,1));
epsilon=0.3;
alpha=0.2;
number_of_wins=0;

for game=1:10000
    
    History=zeros(size(states,1),size(actions,1));
    chain_state_action=[0 0];
    win=0;
    player_sum=0;
    dealer_sum=0;
    number_of_cards=2;
    [new_card]=pick_card(number_of_cards);
    dealer_cards=new_card ;
    dealer_showing_card=dealer_cards(:,1);
    dealer_sum=dealer_sum+sum(new_card);
    [new_card]=pick_card(number_of_cards);
    player_cards=new_card;
    player_sum=player_sum+sum(new_card);
    gift = 0 ;
    
    num_state=find_state_number(states,player_sum,dealer_showing_card);        %finding the state number
    
    find_ace = ismember(1,player_cards) ;
    if find_ace == 1
        extra_action1 = epsilon_greedy(Q,num_state,epsilon) ;
        if extra_action1 == 1
            player_sum = player_sum + 10 ;
            gift = 0.5 ;
        else
            player_sum = player_sum ;
        end
    end
    if player_cards(1) == player_cards(1)
        extra_action2 = epsilon_greedy(Q,num_state,epsilon) ;
        if extra_action2 == 1
            player_cards = player_cards(1) ;
            game_round = 1 ;
            gift = 0.5 ;
        else
            game_round = 2 ;
        end
    end
    game_round = 2 ;
    while(game_round<3)
        napar=0;
        if player_sum<12
            napar=1;
        end
        while(napar)                                                               %get cards untill player sum > 12
            number_of_cards=1;
            [new_card]=pick_card(number_of_cards);
            player_cards=[player_cards new_card];
            player_sum=player_sum+sum(new_card);
            if player_sum>11
                napar=0;
            end
        end
        num_state=find_state_number(states,player_sum,dealer_showing_card);        %finding the state number
        action=epsilon_greedy(Q,num_state,epsilon);                                %choosing the action whether hit or stick
        chain_state_action(1,:)=[num_state action];                                %saving the number of state and its action on that state
        History(num_state,action)=1;
        
        %%player_turn
        nn=2;
        while(action==1 && player_sum<22)                                          %player_sum is smaller than 22 and action, hit is chosen
            number_of_cards = 1;
            [new_card] = pick_card(number_of_cards);
            player_cards = [player_cards new_card];
            player_sum = player_sum+sum(new_card);
            if player_sum>21                                                       %when player_sum is greater than 21
                %player has lost so,it doesnt matter what the player_sum
                player_sum=22;
            end
            num_state=find_state_number(states,player_sum,dealer_showing_card);    %as the player cards has changed, new state should be found
            action=epsilon_greedy(Q,num_state,epsilon);                            %player takes another action whether hit or stick
            chain_state_action(nn,:)=[num_state action];
            History(num_state,action)=1;
            nn=nn+1;
        end
        if (player_sum>21)                                                         %player sums is greater than 21 so player has lost
            %     display('Dealer Wins')
            Return=-1;
        end
        %%dealers turn
        while (player_sum<22 && dealer_sum<22)                                     %both dealer and player cards sums are smaller than 22
            if dealer_sum>player_sum
                %         display('Dealer wins')
                break
            elseif dealer_sum<player_sum                                           %when dealer_sum is smaller that player_sum dealer hits one card
                number_of_cards=1;
                [new_card]=pick_card(number_of_cards);
                dealer_cards=[dealer_cards new_card];
                dealer_sum=dealer_sum+sum(new_card);
            elseif dealer_sum==player_sum                                          %when both dealer and player have the same sums and player sum is smaller than 17 , dealer hits one card
                if player_sum<17
                    number_of_cards=1;
                    [new_card]=pick_card(number_of_cards);
                    dealer_cards=[dealer_cards new_card];
                    dealer_sum=dealer_sum+sum(new_card);
                else
                    %              display('Equal')                                %player_sum is greater than 17 so both player and dealer have the same sums of cards
                    break
                end
            end
        end
        %%final results
        if ((player_sum>dealer_sum) && (player_sum<22))|| (dealer_sum>21)          %player wins when plaler_sum is greater than dealers sum, whilst player_sum is smaller than 22, or when dealer_sum is greater than 21
            display('Player wins');
            Return=1;
            if isempty(gift) == 0
                Return = Return + gift ;
            end
            number_of_wins=number_of_wins+1;
        elseif ((player_sum<dealer_sum)&&(dealer_sum<22)) || (player_sum>21)       %dealer wins when dealer_sum is greater than dealers sum, whilst dealer_sum is smaller than 22, or when player_sum is greater than 21
            display('Dealer wins');
            Return=-1;
        elseif player_sum==dealer_sum                                              %game ends equal when dealer_sum and player_sum are equal
            display('Equal');
            Return=0;
        end
        %%update rule
        for ii=1:size(chain_state_action,1)                                       %updating at the end of the episode using mont-carlo methode
            Q(chain_state_action(ii,1),chain_state_action(ii,2))=Q(chain_state_action(ii,1),chain_state_action(ii,2))+alpha*[Return-Q(chain_state_action(ii,1),chain_state_action(ii,2))];
        end
        epsilon=epsilon*0.9999;
        %     number_of_wins(game)=sum(number_of_wins)+win;
        game_round = game_round + 1 ;
    end
end
for i=1:size(Q,1)
    policy{i,1}=states(i,:);
end
for i=1:size(Q,1)
    if Q(i,1)>=Q(i,2)
        policy{i,2}='hit';
    else
        policy{i,2}='stick' ;
    end
end
