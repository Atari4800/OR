/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Joel and Nick
 * Creation Date: Nov 20, 2021 at 10:37:52 AM
 *********************************************/
//range
range week = 1..52;
range factory = 1..50;

//parameters
int demand[week] = ...;
int fixed_cost[factory] = ...;
int capacity[factory] = ...;
int initial_employees[factory] = ...;

//decision variables
dvar int+ non_trainer[week][factory];
dvar int+ trainer[week][factory];
dvar int+ new_hire[week][factory];
dvar int+ overtime[week][factory];
dvar boolean open[factory];
dvar int+ severance[week][factory];
dvar boolean pay_sev[week][factory];

//objective function
minimize sum(i in week)sum(j in factory)(
            40*14*(non_trainer[i][j] + trainer[i][j])
            + 40*10*new_hire[i][j]
            + 14*1.5*overtime[i][j]
            + open[j]*fixed_cost[j]
            + 40*14*pay_sev[i][j]*abs(severance[i][j]));

//constraints
subject to {
  Demand_hours:
    forall(i in week)sum(j in factory)(40*non_trainer[i][j] + 20*trainer[i][j] + overtime[i][j]) >= demand[i];
  Overtime_limit:
  //should factory be forall or sum?
    forall(i in week)forall(j in factory)((non_trainer[i][j] + trainer[i][j])*10 - overtime[i][j]) >= 0;
  Trainer_limit:
  //any better way to make sure each new hire has a trainer?
    forall(i in week)forall(j in factory)new_hire[i][j] == trainer[i][j];
  Training_time:
  //problems ahoy
    forall(i in week: i > 1)forall(j in factory) new_hire[i-1][j] + trainer[i-1][j] + non_trainer[i-1][j] == trainer[i][j] + non_trainer[i][j] + severance[i][j];
  Initial_split:
  //not splitting it properly
    forall(j in factory)non_trainer[1][j] + trainer[1][j] + severance[1][j] == initial_employees[j];
  Capacity:
  //do we need open[j] any place else?
    forall(i in week)forall(j in factory)40*non_trainer[i][j] + 20*trainer[i][j] + overtime[i][j] <= open[j]*capacity[j];
  If_NJ_then_Oregon:
    open[2] <= open[1];
  NJ_and_or_NY:
    open[2] + open[6] >= 1;
  Positive_people_only:
    forall(i in week)forall(j in factory)trainer[i][j] >= 0;
    forall(i in week)forall(j in factory)non_trainer[i][j] >= 0;
    forall(i in week)forall(j in factory)new_hire[i][j] >= 0;
  
}