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
    eps_p = 0.0001;    // we work with possibility measure P(). interative procedures working with P()-values such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen.
	
// ** Functions with description **
// ptopLoadPoss: Function to load possibility distributions (aka poss-dist) from file
// COMMENT: Each line of poss-dist data in the file represents one distribution p(x) with discreet x=1:qXmax. That means, 'qXmax' is the quantity of p()-values per line and it's value is determined from file formatting. The total count of poss-dists 'qLinesOfData' is also determined from file formatting.
// IN: filename (string)
// OUT: qLinesOfData*qXmax matrix of semi-real numbers normally in range [0, 1] and the lines of text at file beginning before delimiter in sCustomData
function [poss2d, sCustomData] = ptopLoadPoss( sFilename );
    fileID = mopen(filename, 'rt');
    sCustomData = [];
    lline = "This is a buffer";
    while part(lline,1) ~= '*'
        lline = mgetl(fileID, 1);
        sCustomData = [sCustomData; lline];
    end;
    mclose(fileID);
    poss2d = fscanfMat(filename);
endfunction

// ptopLoadPoss3d: same as ptopLoadPoss (see  above), but poss-dist data is reshaped into blocks 
// COMMENT: the block size lqLinesPerBlock is read from first line of file stored in sCustomData; the number of blocks qBlocks=qLinesOfData/qLinesPerBlock 
// IN: filename (string)
// OUT: qLinesPerBlock*qXmax*qBlocks array of semi-real numbers normally in range [0, 1];  
function [poss3d, sCustomData] = ptopLoadPoss3d( sFilename );
    [lposs, sCustomData] = ptopLoadPoss( sFilename );
    lqLinesPerBlock = msscanf(sCustomData(1), "%*s %i");
    lqBlocks = size(lposs,1)/lqLinesPerBlock;
    lqXmax = size(lposs,2);
    poss3d = [];
    for i=1:lqBlocks
        poss3d(:,:,i) = lposs(lqLinesPerBlock*(i-1)+1:lqLinesPerBlock*i,:);
    end;
endfunction
       
// ptopObjSelection: select objects by minimizing P(Error), where Error happens if objects not chosen are not worse in terms of user-defined "quality" then chosen objects and P() is a possibility measure constructed from "expert sasessments" - initial poss-dists of each object's "quality" p(x), x=1:qXmax.
// COMMENT: There are qObj objects and each object has qParam parameters to be assessed in terms of poss-dist prior to run ptopObjSelection. Values of qObj, qParam and also qXmax are generally selected by the Chief. The Chief also must invent a monotonous object quality function qualFun(x(1), ..., x(qParam)) -> y.
// IN: qParam*qXmax*qObj array (assuming 1 expert),
//     qualFun() defined with string 'sQualFun', e.g. sQualFun='y=(x(1)+x(2))/2'  
//  remark #1: if you like to feed ObjSelection directly from a datafile with qParam and sQualFun specified, use ptopObjSelectionFile( filename )
//  First qParam lines of poss-dist data will correspond to the 1-st assessed object and so on.
//  remark #2: if you have more than 1 expert, the 'ptopSup' or 'ptopInf' functions may be called prior to 'ptopObjSelection' to obtain a "collective opinion" as supremum or infinum of the poss-dists. See ptopSup description. 
// OUT is following qObj*qObj matrix (example):
// sel(1)=[0 0 T 0 T 0] -- 3rd and 5th objects
// sel(2)=[0 0 T 0 T 0]
// sel(3)=[T 0 T 0 T T] -- 1st, 3rd, 5th and 6th objects
// ...
// The 'k' is the number of objects to select as a setting; for each setting in range k=1:qObj there is a set of object indeces the Chief may select k from with the SAME possibility or Error for any choice. 
//  remark #1: Additional ouput is a qObj*qObj possibility matrix FOR DEBUG!
exec 'dichotomy.sce'; // load local functions
function [ sel, lPLoser2d ] = ptopObjSelection(poss_init, sQualFun);
    // make a lambda from string
    deff('y=lqualFun(x)', sQualFun);
    [lqParam,lqXmax,lqObj] = size(poss_init);
 //zeros(lqObj,lqObj);
    
    for k=1:lqObj  
     // find P(i)'s for each k
      for i=1:lqObj   
          lPLoser2d(k,i) = lfindPLoser(poss_init, i, k, lqualFun);
          // e.g. lPLoser2d(2,1) is the possibility for the 1-st object not to fit into 2 best objects among 1:lqObj
      end;
     // Find the smallest P(i) for each k that let us select at least k objects and select them and objects equal to them. P(i)'s that are even smaller are wiped out (set to Inf) - we cannot afford such a little Error possibility for given k. Initially no objects are selected.
      lPLoserTemp1d = lPLoser2d(k,:);
      sel(k,:) = ( lPLoserTemp1d ~= lPLoserTemp1d ); 
   ///  print(%io(2), k);
   ///  print(%io(2), sel(k,:));

      while sum( sel(k,:) ) < k
          sel(k,:) = ( lPLoserTemp1d == min(lPLoserTemp1d) );
      ///    print(%io(2), sel(k,:));
          lPLoserTemp1d( sel(k,:) ) = 10;
      end;
    end;
endfunction
// wrapper for file (later html stream) input
function [ sel, lPLoser2d ] = ptopObjSelectionFile( filename )
    [lposs, lsCustomData1d] = ptopLoadPoss3d(filename);
    [ sel, lPLoser2d ] = ptopObjSelection(lposs, lsCustomData1d(2));
endfunction

// The'ptopSup' and similar functions input p[qPossPerExpert, qXmax, qExperts]. When fed with raw data, the first qPossPerExpert poss-dist lines correspond to the 1-st expert's opition and so on.


