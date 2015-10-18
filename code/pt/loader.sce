// This script must be ran to load all availible methods of the general Pytiev's posibility theory (pt) toolbox  as usual Scilab functions.
// 	1. exec loader.sce
// 	2. (call the toolbox functions and other functions you need)

PT_ZERO_POINT = 'B'; // this setting affects the way how zero point (P == 0) is treated:
//                      option 'A': the lowest P-value is always zero (use zero)
//                      option 'B': the lowest P-value is always positive (do not use zero) 
//                      option 'C': P-value is in range [0, 1]&{-1} (use SubZero point as zero)

// Description inside the loaded files:
exec 'input.sce';
exec 'order.sce';
