
// **** PToP Toolbox main script ****
// This script must be ran to load all availible methods of the toolbox as usual Scilab functions.
// 	1. (prepare possibility distributions for input)
// 	2. exec loader.sce
// 	3. (call the toolbox functions and other functions you need)
// Look at http://cmpd2.phys.msu.ru/ptop for beginners' guide

// global const default values (override if needed)
    filename= 'dist.txt'; 
    eps_p = 0.001;    //% we work with possibility meaduse P. interative procedures such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen
	
// function to load expert judgements given in form of possibility distributions aka poss-dist data
function [p, sCustomData] = ptopLoadPoss( filename );
    fileID = mopen(filename, 'rt');
    sCustomData = mgetl(fileID, 1);
    mclose(fileID);
    p = fscanfMat(filename);
endfunction

// In 'ptopObjSelection' function, raw poss-dist data (as soon as loadedwith ptopLoadPoss) will be interpreted as p_init[qParams, qPossPoints, qObj]. That means, assumed only 1 expert, the first qParams poss-dist lines correspond to the 1-st object and so on. If you have more than 1 expert, the 'ptopSup' or 'ptopInf' functions may be called prior to 'ptopObjSelection' to obtain a "collective opinion" as supremum or infinum of the poss-dists. The'ptopSup' and 'ptopInf' functions interpret the data as p[qPossPerExpert, qPossPoints, qExperts], which means, the first qPossPerExpert poss-dist lines correspond to the 1-st expert's opition and so on. 
function  
endfunction


//** this block was to test file-output not needed anymore
//qW = 100; qExperts = 1;
//ptopPossDistr = ones(qW, qExperts);
//format = strcat(['(',string(size(ptopPossDistr,2)),'(f6.3,2x))']);
//write(filename, ptopPossDistr, format);


