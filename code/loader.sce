// **** PToP Toolbox main script ****
// This script must be ran to load all availible methods of the toolbox as usual Scilab functions.
// 	1. (prepare possibility distributions for input)
// 	2. exec loader.sce
// 	3. (call the toolbox functions and other functions you need)
// TODO: make http://cmpd2.phys.msu.ru/ptop beginners' guide

// ** Syntax description **
// [l][sq]VarName[Nd]: 
//  l - local var; omitted in descriptions 
//  s - string, q - integer, no prefix - standard real var (single or double)
//  Nd - number of dimensions, e.g. 2d for matrices; may be omitted
// ptopFuncName: "global" toolbox functions
// lfuncName: "local" functions
// J, 

// ** Global default values (override if needed) **
    filename= 'dist.txt'; 
    eps_p = 0.001;    // we work with possibility measure P(). interative procedures working with P()-values such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen.
	
// ** Functions with description **
// ptopLoadPoss: Function to load possibility distributions (aka poss-dist) from file
// COMMENT: Each line of poss-dist data in the file represents one distribution p(x) with discreet x=1:qXmax. That means, 'qXmax' is the quantity of p()-values per line and it's value is determined from file formatting. The total count of poss-dists 'qLinesOfData' is also determined from file formatting.
// IN: filename (string)
// OUT: qLinesOfData*qXmax matrix of semi-real numbers normally in range [0, 1]
function [poss2d, sCustomData] = ptopLoadPoss( sFilename );
    fileID = mopen(filename, 'rt');
    lline = "===The following is a custom prelude to poss-dist data===";
    sCustomData = [];
    while part(lline,1) ~= '*'
        sCustomData = [sCustomData; lline];
        lline = mgetl(fileID, 1);
    end
    mclose(fileID);
    poss2d = fscanfMat(filename);
endfunction

// ptopLoadPoss3d: same as ptopLoadPoss (see  above), but poss-dist data is reshaped into blocks 
// COMMENT: the block size lqLinesPerBlock is read from first line of file; the number of blocks qBlocks=qLinesOfData/qLinesPerBlock 
// IN: filename (string)
// OUT: qLinesPerBlock*qXmax*qBlocks array of semi-real numbers normally in range [0, 1];  
function [poss3d, sCustomData] = ptopLoadPoss3d( sFilename );
    [lposs, sCustomData] = ptopLoadPoss( sFilename );
    lqLinesPerBlock = msscanf(sCustomData(2), "%*s %i");
    lqBlocks = size(lposs,1)/lqLinesPerBlock;
    lqXmax = size(lposs,2);
    poss3d = [];
    for i=1:lqBlocks
        poss3d(:,:,i) = lposs(lqLinesPerBlock*(i-1)+1:lqLinesPerBlock*i,:);
    end
endfunction
       
// ptopObjSelection: select objects by minimizing P(Error), where Error happens if objects not chosen are not worse in terms of user-defined "quality" then chosen objects and P() is a possibility measure constructed from "expert sasessments" - initial poss-dists of each object's "quality" p(x), x=1:qXmax.
// COMMENT: There are qObj objects and each object has qParam parameters to be assessed in terms of poss-dist prior to run ptopObjSelection. Values of qObj, qParam and also qXmax are generally selected by the Chief. The Chief also must invent a monotonous object quality function qualFun(x(1), ..., x(qParam)) -> y.
// IN: qParam*qXmax*qObj array (assuming 1 expert),
//     qualFun() defined with string 'sQualFun', e.g. sQualFun='y=(x(1)+x(2))/2'  
//  remark #1: if you like to feed ObjSelection directly from a datafile with qParam and sQualFun specified in fist line, use 'ptopObjSelection(ptopLoadPoss3d( filename ))'. First qParam lines of poss-dist data will correspond to the 1-st assessed object and so on.
//  remark #2: if you have more than 1 expert, the 'ptopSup' or 'ptopInf' functions may be called prior to 'ptopObjSelection' to obtain a "collective opinion" as supremum or infinum of the poss-dists. See ptopSup description. 
// OUT of 'ptopObjSelection' is a following struct (example):
// k=1: ua={},a={3,5}
// k=2: ua={3,5},a={}
// k=3: ua={3,5},a={4,6,1}  etc.
// The 'k' is the number of objects to select as a setting; for each setting in range k=1:qObj there are two sets of object indeces, the first one to be an unabmigious selection of size r<=k and the second one to be an ambigious selection with "equally good" assessed objects from which to choose r-k objects randomly or to choose other 'k' value.
exec 'dichotomy.sce'; // load local functions
function [ sel ] = ptopObjSelection(poss_init, sQualFun);
    // make a lambda from string
    deff('y=lqualFun(x)', sQualFun);
    [lqParam,lqXmax,lqObj] = size(p_init);
    
    k=1; // TODO: add loop on k
    for i=1:lqObj   
        P_loser(i) = lfindPLoser(poss_init, i, k);
    end
endfunction


// The'ptopSup' and similar functions input p[qPossPerExpert, qXmax, qExperts]. When fed with raw data, the first qPossPerExpert poss-dist lines correspond to the 1-st expert's opition and so on.


