function [new_card]=pick_card(number_of_cards)
cards=[1 2 3 4 5 6 7 8 9 10 10 10 10];
for i=1:number_of_cards
   
    n=randi(13);
    new_card(i)=cards(n);
end