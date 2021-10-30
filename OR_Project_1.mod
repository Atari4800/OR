/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Joel and Nick
 * Creation Date: Oct 9, 2021 at 2:21:20 PM
 *********************************************/
//Ranges
range beam = 1..5;
range month = 1..12;

//Parameter
float beam_selling_price[beam] = [1000,750,1500,1200,800]; //p
float demand[beam][month] = ...; //d
float penalty[beam] = [100,300,250,600,1000]; //p
float min_percent_needed[beam] = [0.4,0.2,0.6,0.1,0.25]; //p
float price_per_ton_rec = 400;
float price_per_ton_new = 600;
float new_steel_purchase_limit = 5000;
float rec_steel_purchase_limit = 6000;
float hold_over_cost = 40;
float usable_rec_steel = 0.8;

//Decision Variables
dvar float+ rec_steel_purchased[beam][month]; //x
dvar float+ new_steel_purchased[beam][month]; //y
dvar float+ inventory[beam][month]; //n
dvar float+ beams_made[beam][month]; //m
dvar float+ backorder[beam][month]; //b

//Objective Function
maximize sum(i in beam)(sum(j in month)(beam_selling_price[i]*(beams_made[i][j] - backorder[i][j])))
            - sum(i in beam)sum(j in month)(new_steel_purchased[i][j]*price_per_ton_new)
            - sum(i in beam)sum(j in month)(rec_steel_purchased[i][j]*price_per_ton_rec)
            - sum(i in beam)(sum(j in month)(penalty[i]*backorder[i][j]))
            - sum(i in beam)(sum(j in month)(inventory[i][j]*hold_over_cost));
            
//Constraints
subject to {
  Relation:
    forall(i in beam)forall(j in month)beams_made[i][j] == new_steel_purchased[i][j] + usable_rec_steel*rec_steel_purchased[i][j];
  Purchase_Limit:
    forall(i in beam)forall(j in month)new_steel_purchased[i][j] <= new_steel_purchase_limit;
    forall(i in beam)forall(j in month)rec_steel_purchased[i][j] <= rec_steel_purchase_limit;
  Min_Percent_New_Steel:
    forall(i in beam)forall(j in month)new_steel_purchased[i][j] >= min_percent_needed[i]*(usable_rec_steel*rec_steel_purchased[i][j] + new_steel_purchased[i][j]);
  Initial_Inventory:
    forall(i in beam)beams_made[i][1] + backorder[i][1] == demand[i][1] + inventory[i][1];
  Inventory:
    forall(i in beam)forall(j in month: j > 1)backorder[i][j] + beams_made[i][j] + inventory[i][j - 1] == inventory[i][j] + demand[i][j] + backorder[i][j - 1];
  Empty_Month_12:
    forall(i in beam)backorder[i][12] == 0;
    forall(i in beam)inventory[i][12] == 0;
}
