/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Joel
 * Creation Date: Oct 9, 2021 at 2:21:20 PM
 *********************************************/
//Ranges
range month = 1..12;
range beam = 1..5;
range steel = 1..2;

//Parameter
float beam_selling_price[beam] = [1000,750,1500,1200,800];
float demand[month][beam] = ...;
float penalty[beam] = [100,300,250,600,1000];
float min_percent_needed[beam] = [0.4,0.2,0.6,0.1,0.25];
float price_per_ton[steel] = [400,600];
float steel_purchase_limit[steel] = [5000,6000];
//float money[month];

//Decision Variables
dvar float+ steel_purchased[month][steel];
dvar float+ inventory[month][beam];
dvar float+ beams_made[month][steel][beam];
dvar float+ not_filled[month][beam];
dvar float+ percent_new_steel[month][beam];

//Objective Function
maximize sum(i in month)(sum(j in beam)(beam_selling_price[j]*(demand[i][j] - not_filled[i][j])))
            - sum(i in month)(sum(j in beam)(sum(k in steel)(price_per_ton[k]*beams_made[i][j][k])))
            - sum(i in month)(sum(j in beam)(40*inventory[i][j]))
            - sum(i in month)(sum(j in beam)(not_filled[i][j]*penalty[j]));
            
//Constraints
subject to {
  Purchase_Limit:
    forall(i in month)forall(j in steel)steel_purchased[i][j] <= steel_purchase_limit[j];
  Iventory_Balance:
    forall(i in month: i > 1)forall(j in beam)forall(k in steel)inventory[i-1][j] + beams_made[i-1][k][j] == inventory[i][j] + demand[i][j] - not_filled[i][j];
  Initial_inventory:
    forall(j in beam)forall(k in steel)beams_made[1][k][j] == inventory[1][j] + demand[1][j] - not_filled[1][j];
  Min_Percent_new_steel:
    forall(i in month)forall(j in beam)steel_purchased[i][1]*percent_new_steel[i][j] + steel_purchased[i][2]*(1-percent_new_steel[i][j]) == 1000000000; // we dont know...
    forall(i in month)forall(j in beam)percent_new_steel[i][j] >= min_percent_needed[j];
  //Trash_Steel:
    //forall(i in month)usable_steel_purchased[i][1] == 0.8*steel_purchased[i][1]; // we dont know...
}

//PostProcessing
execute {
   
}
