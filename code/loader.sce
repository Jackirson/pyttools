// **** Pytiev Theory of Possibility (pt) Toolbox main script ****
// This script must be ran to load all availible methods of the toolbox as usual Scilab functions.
// 	1. (prepare possibility distributions for input)
// 	2. exec loader.sce
// 	3. (call the toolbox functions and other functions you need)
// TODO: make http://cmpd2.phys.msu.ru/pt beginners' guide

// ** Syntax description **
// [l][sq]VarName[Nd]: 
//  l - local var; omitted in descriptions 
//  s - string, q - integer, no prefix - standard real var (single or double)
//  Nd - number of dimensions, e.g. 2d for matrices; may be omitted
// ptFuncName: "global" toolbox functions
// hptFuncName: "help" functions
// lfuncName: "local" functions

// ** Global default values (uncomment if needed) **
    filename= 'distReal.txt'; 
    eps_p = -1;    // we work with possibility measure P(). interative procedures working with P()-values such as Dichotomy will run until |dP| < eps_p, or they will try to find a precise solution if eps_p < 0 chosen.
	
// ** Functions with description **
exec 'dichotomy.sce'; // load local functions

// ptLoadPoss: Function to load possibility distributions (aka poss-dist) from file
// COMMENT: Each line of poss-dist data in the file represents one distribution p(x) with discreet x=1:qXmax. That means, 'qXmax' is the quantity of p()-values per line and it's value is determined from file formatting. The total count of poss-dists 'qLinesOfData' is also determined from file formatting.
// IN: filename (string)
// OUT: qLinesOfData*qXmax matrix of semi-real numbers normally in range [0, 1] and the lines of text at file beginning before delimiter in sCustomData
function [poss2d, sCustomData] = ptLoadPoss( sFilename );
    fileID = mopen(sFilename, 'rt');
    sCustomData = [];
    lline = "This is a buffer";
    while part(lline,1) ~= '*'
        lline = mgetl(fileID, 1);
        sCustomData = [sCustomData; lline];
    end;
    mclose(fileID);
    poss2d = fscanfMat(sFilename);
endfunction

// ptLoadPoss3d: same as ptLoadPoss (see  above), but poss-dist data is reshaped into blocks 
// COMMENT: the block size lqLinesPerBlock is read from first line of file stored in sCustomData; the number of blocks qBlocks=qLinesOfData/qLinesPerBlock 
// IN: filename (string)
// OUT: qLinesPerBlock*qXmax*qBlocks array of semi-real numbers normally in range [0, 1];  
function [poss3d, sCustomData] = ptLoadPoss3d( sFilename );
    [lposs, sCustomData] = ptLoadPoss( sFilename );
    lqLinesPerBlock = msscanf(sCustomData(1), "%*s %i");
    lqBlocks = size(lposs,1)/lqLinesPerBlock;
    lqXmax = size(lposs,2);
    poss3d = [];
    for i=1:lqBlocks
        poss3d(:,:,i) = lposs(lqLinesPerBlock*(i-1)+1:lqLinesPerBlock*i,:);
    end;
endfunction
       
// ptObjSelection: select objects by minimizing P(Error), where Error happens if objects not chosen are not worse in terms of user-defined "quality" then chosen objects and P() is a possibility measure constructed from "expert sasessments" - initial poss-dists of each object's "quality" p(x), x=1:qXmax.
// COMMENT: There are qObj objects and each object has qParam parameters to be assessed in terms of poss-dist prior to run ptObjSelection. Values of qObj, qParam and also qXmax are generally selected by the Chief. The Chief also must invent a monotonous object quality function qualFun(x(1), ..., x(qParam)) -> y.
// IN: qParam*qXmax*qObj array (assuming 1 expert),
//     qualFun() defined with string 'sQualFun', e.g. sQualFun='y=(x(1)+x(2))/2'  
//  remark #1: if you like to feed ObjSelection directly from a datafile with qParam and sQualFun specified, use ptObjSelFile( filename )
//  First qParam lines of poss-dist data will correspond to the 1-st assessed object and so on.
//  remark #2: if you have more than 1 expert, the 'ptSup' or 'ptInf' functions may be called prior to 'ptObjSelection' to obtain a "collective opinion" as supremum or infinum of the poss-dists. See ptSup description. 
// OUT: two following qObj*qObj boolean matrices(example):
// sel(1)=[0 0 T 0 T 0] -- 3rd and 5th objects
// sel(2)=[0 0 T 0 T 0]
// sel(3)=[T 0 T 0 T T] -- 1st, 3rd, 5th and 6th objects
// ...
// There is a number 'k' of objects to select as a setting; for each setting in range k=1:qObj there is a set  of object indeces with size >= k the Chief may select k from with the SAME possibility or Error for any choice - these sets are stored to sel(k,:,1). There is also a set of object indexes for each k of a maximum size that is <= k, but induces a lower possibility of Error - they are stored to sel(k,:,2) and interpreted as objects that "must be chosen" (?)
//  remark #1: Additional ouput is a qObj*qObj possibility matrix FOR DEBUG!
function [ sel, lPLoser2d ] = ptObjSelection(poss_init, sQualFun);
    // make a lambda from string
    deff('y=lqualFun(x)', sQualFun);
    [lqParam,lqXmax,lqObj] = size(poss_init);

    for k=1:lqObj  
     // find P(i)'s for each k
      for i=1:lqObj   
          lPLoser2d(k,i) = lfindPLoser(poss_init, i, k, lqualFun);
          // e.g. lPLoser2d(2,1) is the possibility for the 1-st object not to fit into 2 best objects among 1:lqObj
      end;

      lPLoserTemp1d = lPLoser2d(k,:);
      sel(k,:, 1) = ( lPLoserTemp1d ~= lPLoserTemp1d ); // initialize with "false"
      sel(k,:, 2) = ( lPLoserTemp1d ~= lPLoserTemp1d ); // initialize with "false"
      while sum( sel(k,:, 1) ) < k
          // sel(:,:,1) is a set object indeces 'i' with P_i that induce minimum P(E) when taken at least k objects (i.e. size(sel(k,:,1)>=k)
          sel(k,:, 2) = sel(k, : ,1);  // the sel on previous step is of size <= k and with less P(E)
          sel(k,:, 1) = sel(k,:, 1) | ( lPLoserTemp1d == min(lPLoserTemp1d) );  // add objects with greater error possibility until we have at least k objects in set
          lPLoserTemp1d( sel(k,:, 1) ) = 10; // wipe out the miniumium values of P_l to find next minimum values on next loop
      end;
    end;
endfunction

// ptObjSelFile: wrapper to ptObjSelection for file (later http stream) input 
// IN: filename
// OUT: same as ptObjSelection 
function [ sel, lPLoser2d ] = ptObjSelFile( filename )
    [lposs, lsCustomData1d] = ptLoadPoss3d(filename);
 
    [ sel, lPLoser2d ] = ptObjSelection(lposs, lsCustomData1d(2));
endfunction

// pthPrintSel: help function to print "smart" output of ptObjSelection
// IN: 'sel' from ptObjSelection
// PRINT: prints the output in text form
// OUT: list of size k with two lists of chosen objcts (instead of two boolean matrices)
//       sel(k)(1) is "mandatory" selection (size <= k), sel(k)(2) is "additional" selection (size >= k)
function sel = ptPrintSel(sel3d)
    lqObj = size(sel3d, 1);
    lObjects = 1:lqObj; // set of all object indeces

    sel = list();
    for k = 1:lqObj
         sel(k) = list();
         mprintf("For k=%i ",k);
         if sum( sel3d(k,:,1) ) == k   // if selection is precise
             sel(k)(1) =  lObjects(sel3d(k,:,1)); // mandatory set is precise
             sel(k)(2) = []; // optional set is empty 
             mprintf("(precise): ");
         else
             sel(k)(1) =  lObjects(sel3d(k,:,2)); // mandatory set is taken from prevoius-step sel (see ptObjSelection)
              sel(k)(2) =  lObjects(sel3d(k,:,1) & ~sel3d(k,:,2)); // optional set is the common sel without mandatory set
             mprintf("(ambigious): ");
         end//if
         
         // ===print 1-st set
         for  i=1:length(sel(k)(1))
             mprintf("%i ", sel(k)(1)(i)); 
         end
         if length(sel(k)(2))>0 then mprintf(" | "); end;
         // ===print 2-nd set
         for  i=1:length(sel(k)(2))
             mprintf("%i ", sel(k)(2)(i)); 
         end            
         mprintf("\n");
    end    
endfunction

// The'ptSup' and similar functions input p[qPossPerExpert, qXmax, qExperts]. When fed with raw data, the first qPossPerExpert poss-dist lines correspond to the 1-st expert's opition and so on.

