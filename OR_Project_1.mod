/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Joel and Nick
 * Creation Date: Oct 9, 2021 at 2:21:20 PM
 *********************************************/
//Ranges
range month = 1..12;
range beam = 1..5;

//Parameter
float beam_selling_price[beam] = [1000,750,1500,1200,800];
float demand[beam][month] = ...;
float penalty[beam] = [100,300,250,600,1000];
float min_percent_needed[beam] = [0.4,0.2,0.6,0.1,0.25];
float price_per_ton_rec = 400;
float price_per_ton_new = 600;
float new_steel_purchase_limit = 5000;
float rec_steel_purchase_limit = 6000;
float hold_over_cost = 40;
float usuable_rec = 0.8;

//Decision Variables
dvar float+ rec_steel_purchased[month];
dvar float+ new_steel_purchased[month];
dvar float+ inventory[beam][month];
dvar float+ beams_made[beam][month];
dvar float+ not_filled[beam][month];
dvar float+ percent_new_steel[beam][month];

//Objective Function
maximize sum(i in beam)(sum(j in month)(beam_selling_price[i]*beams_made[i][j]))
            - sum(j in month)new_steel_purchased[j]*price_per_ton_new
            - sum(j in month)rec_steel_purchased[j]*price_per_ton_rec
            - sum(i in beam)(sum(j in month)(penalty[i]*not_filled[i][j]))
            - sum(i in beam)(sum(j in month)(inventory[i][j]*hold_over_cost))
            ;
            
//Constraints
subject to {
  Purchase_Limit:
    forall(i in month)new_steel_purchased[i] <= new_steel_purchase_limit;
    forall(i in month)rec_steel_purchased[i] <= rec_steel_purchase_limit;
  Min_Percent_new_steel:
    forall(i in beam)forall(j in month)new_steel_purchased[j] >= min_percent_needed[i]*(usuable_rec*rec_steel_purchased[j] + new_steel_purchased[j]);
  Initial_Inventory:
    forall(i in beam)inventory[i][1] + demand[i][1] - not_filled[i][1] == beams_made[i][1];
  Inventory:
    forall(i in beam)forall(j in month: j > 1)inventory[i][j] + demand[i][j] - not_filled[i][j] == inventory[i][j - 1] + beams_made[i][j - 1];
  Demand:
    forall(i in beam)forall(j in month)beams_made[i][j] >= demand[i][j] + not_filled[i][j];
}
