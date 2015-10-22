// This script must be ran (from toolbox root folder) to load all availible methods of both general posibility theory (pt) toolbox and P-based evaluation subtoolbox (pev) as usual Scilab functions.
//	1. cd %TOOLBOX_ROOT_FOLDER;
// 	2. exec loader.sce;
// 	3. (call the toolbox functions and other functions you need)

filename= 'data/distReal.txt';  // a sample data file with possibility distributions (poss-dists)

// Description inside the loaded files:
cd pt;
exec 'loader.sce';

cd ../pev;
exec 'loader.sce';

cd ..;
// eof===eof===eof

