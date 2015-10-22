// This script must be ran to load all availible methods of the P-based evaluation subtoolbox (pev) as usual Scilab functions. WARNING: this is a subtoolbox and its methods require the generel posibility theory (pt) toolbox to be loaded. Usually you DO NOT have to run this script manually. Run loader.sce from your installation's root directory of instead.

PEV_EPS_P = -1;    // we work with possibility measure P(). interative procedures working with P()-values such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen (this is the default and usually faster option)

// Description inside the loaded files:
exec 'select_dichotomy.sce';
exec 'select.sce';
