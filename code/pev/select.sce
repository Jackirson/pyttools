// Procedures to select objects (make a decision, choose a selection). If you don't know where to start, type 
//    pevPrintResult( pevSelectF( filename ) );
// and then read comments below.
// ===================  
// pevSelect: select objects by minimizing P(Error), where Error happens if objects not chosen are not worse in terms of user-defined "quality" then chosen objects and P() is a possibility measure constructed from "expert sasessments" - initial poss-dists of each object's "quality" p(x), x=1:qXmax.
// COMMENT: There are qObj objects and each object has qParam parameters to be assessed in terms of poss-dist prior to run pevSelect. Values of qObj, qParam and also qXmax are generally selected by the Chief. The Chief also must invent a monotonous object quality function qualFun(x1, ..., xM)) -> y, M = qParam. 
// IN: qParam*qXmax*qObj array (assuming 1 expert),
//     string 'sQualFun', e.g. sQualFun='y=(x1+x2)/2'  
//  remark #1: if you like to feed Select directly from a datafile with qParam and sQualFun specified, use pevSelectF( filename )
//  First qParam lines of poss-dist data will correspond to the 1-st assessed object and so on.
//  remark #2: if you have more than 1 expert, the 'ptSup' or 'ptInf' functions may be called prior to 'ptObjSelection' to obtain a "collective opinion" as supremum or infinum of poss-dists. See file 'supremum.sce'. 
// OUT: two following qObj*qObj boolean matrices(example):
// sel(1)=[F F T F T F] -- 3rd and 5th objects
// sel(2)=[F F T F T F]
// sel(3)=[T F T F T T] -- 1st, 3rd, 5th and 6th objects
// ...
// There is a number 'k' of objects to select as a setting; for each setting in range k=1:qObj there is a set of object indeces of size >= k the Chief may select k from with the SAME possibility or Error for any choice - these sets are stored to sel(k,:,1). There is also a set of object indexes for each k of size <= k, but induces a strictly lower possibility of Error - they are stored to sel(k,:,2) if exist (otherwise sel(k,:,2) are all False).
//  remark #1: Additional ouput is a qObj*qObj possibility matrix FOR DEBUG!
function [ sel, PLoser2d ] = pevSelect(poss_init, sQualFun);

    sQualFunParsed = lParseQualFun( sQualFun );
    deff('y=qualFun(x)', sQualFun);     // make a lambda from string
    [qParam_notUsed,qXmax_notUsed,qObj] = size(poss_init);
    sel = zeros(qObj,qObj,2);

    for k=1:qObj  
      for i=1:qObj   
          PLoser2d(k,i) = lFindPLoser(poss_init, i, k, qualFun);   // possibility for object i not to fit into k best objects among 1:qObj
      end;

      PLoserTemp1d = PLoser2d(k,:);
    ///  sel(k,:, 1) = ( PLoserTemp1d ~= PLoserTemp1d ); 
    ///  sel(k,:, 2) = ( PLoserTemp1d ~= PLoserTemp1d ); // same shit
      // zeroes in sel(k,:,:) will turn to %F when a boolean expression (a == b) is assigned below. it's important for indexing style float_matrix(bool_matrix)
      while sum( sel(k,:, 1) ) < k // until we have sel at least k objects
          sel(k,:, 2) = sel(k, : ,1);  // sel on previous step is of size <= k and with less P(E)
          sel(k,:, 1) = sel(k,:, 1) | ( PLoserTemp1d == min(PLoserTemp1d) );  // add objects with minimal P(E) 
          PLoserTemp1d( sel(k,:, 1) ) = 10; // wipe out the miniumium values to find next minimum values
      end;
    end;
endfunction
// ===================
// pevPrintResult: wrapper to pevSelect for file (later http stream) input 
// IN: filename
// OUT: same as pevSelect 
function [ sel, PLoser2d ] = pevSelectF( filename )
    [poss, sData1d] = ptLoadPoss3d(filename);
 
    [ sel, PLoser2d ] = pevSelect(poss, sData1d(2));
endfunction
// ===================
// pevPrintResult: function to print "smart" output of pevSelect (later maybe also something else)
// IN: 'sel' from pevSelect
// PRINT: prints the output in text form
// OUT: list of size k with two lists of chosen objcts (instead of two boolean matrices)
//       sel(k)(1) is "mandatory" selection (size <= k), sel(k)(2) is "additional" selection (size >= k)
function sel = pevPrintResult(sel3d)
    qObj = size(sel3d, 1);
    Objects = 1:qObj; // set of all object indeces

    sel = list();
    for k = 1:qObj
         sel(k) = list();
         mprintf("For k=%i ",k);
         if sum( sel3d(k,:,1) ) == k    // if selection is clear (unambiguous)
             sel(k)(1) =  Objects(sel3d(k,:,1)); // mandatory set is clear
             sel(k)(2) = [];                      // additional set is empty 
             mprintf("(clear): ");
         else                           // if selection is ambiguous 
              // mandatory set is sel of size <= k (with less P(E))
              sel(k)(1) =  Objects(sel3d(k,:,2));   
              // additional set is sel of size >=k without mandatory set
              sel(k)(2) =  Objects(sel3d(k,:,1) & ~sel3d(k,:,2)); 
             mprintf("(ambiguous): ");
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
    end//for    
endfunction
// ==eof===eof==

