// **** Pytyev's Possibility Theory (pt) Toolbox and P-based Evaluation (pev) SubToolbox ****
// TODO: make http://cmpd2.phys.msu.ru/pt beginners' guide

// ** Syntax description **
// PT_GLOBAL_CONSTANT_NAME
// [sq]VarName[Nd]: 
//  s - string, q - single integer, no prefix - standard (real or int array)
//  Nd - number of dimensions, e.g. 2d for matrices; may be omitted
// ptFuncName: global Pytiev toolbox functions
// evFuncName: global 
// lfuncName: "local"-only functions

The toolbox actually consists of two parts:

I)  The functions designed to perform the basic Pytyev's Possibility Theory (pt)
operations. 

II) The functions designed to evaluate technologies under uncertainty.
Generally, these functions can be used to evaluate not only technologies,
but everything a decision maker wants to evaluate. So let's call this problem
simply "evaluation".

Prefix "pt" is used for function from group I and "pev" for group II. There is a loader.sce script in both "possibility" and "evaluation" directories, and a loader.sce script in the root directory executing both pt/loader.sce and pev/loader.sce.
