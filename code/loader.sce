// **** Pytiev Theory of Possibility (pt) Toolbox main script ****
// This script must be ran to load all availible methods of the toolbox as usual Scilab functions.
// 	1. (prepare possibility distributions for input)
// 	2. exec loader.sce
// 	3. (call the toolbox functions and other functions you need)
// TODO: make http://cmpd2.phys.msu.ru/pt beginners' guide

// ** Syntax description **
// PT_GLOBAL_CONSTANT_NAME
// [sq]VarName[Nd]: 
//  s - string, q - single integer, no prefix - standard (real or int array)
//  Nd - number of dimensions, e.g. 2d for matrices; may be omitted
// ptFuncName: "global" toolbox functions
// lptfuncName: "local" functions

// ** Globals **
    filename= 'data/distReal.txt';  // a macro for copy-paste
    PT_EPS_P = -1;    // we work with possibility measure P(). interative procedures working with P()-values such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen.
	
// ** Functions with description in corresp. files **
exec 'input.sce';
exec 'objsel.sce';
exec 'supremum.sce';

