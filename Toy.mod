
{string} ToyTypes = ...;
{string} ComponentTypes = ...;

int NbPeriods = ...;
range Periods = 1..NbPeriods;

// Maximum production per period
int MaxBuildPerPeriod[Periods] = ...;  
// Maximum demand per toy type per period
int MaxDemand[ToyTypes][Periods] = ...;  
// Minimum demand per toy type per period
int MinDemand[ToyTypes][Periods] = ...;  

// Tuple representing a toy to produce
tuple toysToBuild {   
   {string} components;
   int      price;
   int      maxInventory;
}

toysToBuild Toys[ToyTypes] = ...;
// Total production of each toy type
float TotalBuild[ToyTypes] = ...;  

int MaxInventory = 25;

// Decision variables for production
dvar float+ Build[ToyTypes][Periods]; 
// Decision variables for sales
dvar float+ Sell[ToyTypes][Periods];  
// Decision variables for inventory
dvar float+ InStockAtEndOfPeriod[ToyTypes][Periods];  

subject to {
  
// Inventory capacity constraint
  forall(p in Periods)
    ctInventoryCapacity:
      sum(t in ToyTypes) InStockAtEndOfPeriod[t][p] <= MaxInventory;
      
// Maximum demand constraint
  forall(t in ToyTypes, p in Periods)
    ctUnderMaxDemand: Sell[t][p] <= MaxDemand[t][p];
    
// Maximum inventory constraint
  forall(t in ToyTypes, p in Periods)
    ctToyTypeInventoryCapacity:
      InStockAtEndOfPeriod[t][p] <= Toys[t].maxInventory;
      
// Minimum demand constraint
  forall(t in ToyTypes, p in Periods)
    ctOverMinDemand: Sell[t][p] >= MinDemand[t][p];
    
// Initial inventory constraint
  forall(t in ToyTypes)
    Build[t][1] == Sell[t][1] + InStockAtEndOfPeriod[t][1];
    
// Production capacity constraint
  forall(t in ToyTypes)
    ctTotalToBuild:
      sum(p in Periods) Build[t][p] == TotalBuild[t];
      
// Inventory balance constraint
  forall(t in ToyTypes, p in 2..NbPeriods)
    ctInventoryBalance:
      InStockAtEndOfPeriod[t][p-1] + Build[t][p] ==
        Sell[t][p] + InStockAtEndOfPeriod[t][p];
}