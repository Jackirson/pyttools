// Procedures to select objects (make a decision, choose a selection). If you don't know where to start, type 
//    ptPrintSel( ptObjSelFile( filename );
// and then read comments below.
// ===================  
// ptObjSelection: select objects by minimizing P(Error), where Error happens if objects not chosen are not worse in terms of user-defined "quality" then chosen objects and P() is a possibility measure constructed from "expert sasessments" - initial poss-dists of each object's "quality" p(x), x=1:qXmax.
// COMMENT: There are qObj objects and each object has qParam parameters to be assessed in terms of poss-dist prior to run ptObjSelection. Values of qObj, qParam and also qXmax are generally selected by the Chief. The Chief also must invent a monotonous object quality function qualFun(x1, ..., xM)) -> y, M = qParam. 
// IN: qParam*qXmax*qObj array (assuming 1 expert),
//     string 'sQualFun', e.g. sQualFun='y=(x1+x2)/2'  
//  remark #1: if you like to feed ObjSelection directly from a datafile with qParam and sQualFun specified, use ptObjSelFile( filename )
//  First qParam lines of poss-dist data will correspond to the 1-st assessed object and so on.
//  remark #2: if you have more than 1 expert, the 'ptSup' or 'ptInf' functions may be called prior to 'ptObjSelection' to obtain a "collective opinion" as supremum or infinum of poss-dists. See file 'supremum.sce'. 
// OUT: two following qObj*qObj boolean matrices(example):
// sel(1)=[F F T F T F] -- 3rd and 5th objects
// sel(2)=[F F T F T F]
// sel(3)=[T F T F T T] -- 1st, 3rd, 5th and 6th objects
// ...
// There is a number 'k' of objects to select as a setting; for each setting in range k=1:qObj there is a set of object indeces of size >= k the Chief may select k from with the SAME possibility or Error for any choice - these sets are stored to sel(k,:,1). There is also a set of object indexes for each k of size <= k, but induces a strictly lower possibility of Error - they are stored to sel(k,:,2) if exist (otherwise sel(k,:,2) are all False).
//  remark #1: Additional ouput is a qObj*qObj possibility matrix FOR DEBUG!
function [ sel, PLoser2d ] = ptObjSelection(poss_init, sQualFun);

    sQualFunParsed = lptParseQualFun( sQualFun );
    deff('y=qualFun(x)', sQualFun);     // make a lambda from string
    [qParam_notUsed,qXmax_notUsed,qObj] = size(poss_init);

    for k=1:qObj  
      for i=1:qObj   
          PLoser2d(k,i) = lptFindPLoser(poss_init, i, k, qualFun);   // possibility for object i not to fit into k best objects among 1:qObj
      end;

      PLoserTemp1d = PLoser2d(k,:);
      sel(k,:, 1) = ( PLoserTemp1d ~= PLoserTemp1d ); // initialize with "false"
      sel(k,:, 2) = ( PLoserTemp1d ~= PLoserTemp1d ); // same shit
      while sum( sel(k,:, 1) ) < k // until we have sel at least k objects
          sel(k,:, 2) = sel(k, : ,1);  // sel on previous step is of size <= k and with less P(E)
          sel(k,:, 1) = sel(k,:, 1) | ( PLoserTemp1d == min(PLoserTemp1d) );  // add objects with minimal P(E) 
          PLoserTemp1d( sel(k,:, 1) ) = 10; // wipe out the miniumium values to find next minimum values
      end;
    end;
endfunction
// ===================
// ptObjSelFile: wrapper to ptObjSelection for file (later http stream) input 
// IN: filename
// OUT: same as ptObjSelection 
function [ sel, PLoser2d ] = ptObjSelFile( filename )
    [poss, sData1d] = ptLoadPoss3d(filename);
 
    [ sel, PLoser2d ] = ptObjSelection(poss, sData1d(2));
endfunction
// ===================
// ptPrintSel: help function to print "smart" output of ptObjSelection
// IN: 'sel' from ptObjSelection
// PRINT: prints the output in text form
// OUT: list of size k with two lists of chosen objcts (instead of two boolean matrices)
//       sel(k)(1) is "mandatory" selection (size <= k), sel(k)(2) is "additional" selection (size >= k)
function sel = ptPrintSel(sel3d)
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
//=====================================//
// Below are functions for local usage //
//DICHOTOMY (the heart of dichotomy) answers the question: is it true that
// P( object l(oser) doesn't fit into k maximum sum values ) > p_level ?
function [ answer ] = lptDichotomyPLoser( p, p_level, l, K, sum_function ) // math symbols used here as variable names and 'l' for locals omitted
    [M,Xmax,N] = size(p);

    // index-to-value array: x(r) = r, r=1..Xmax
    // useful to find max_r(r|conditions)
    X3d = zeros(M,Xmax,N);
    for x = 1:Xmax   
        X3d(:,x,:) = x-1; 
    end
 
    // select only points x in 1..Xmax: p(x) > p_level
 ///   print(%io(2),l,K,p_level); pause
    
    X3d = X3d .* ( p > p_level );
    
    // Construction of T_edge: give best points for all objects i=1..N except i=l ans worst points for object l
    // 1. select best points as maximum in each row of 
    T_edge3d =  max(X3d, 'c');  // sum into single column along rows: M*1*N
  //  T_edge2d = T_edge3d(:,:);  // a sideway concatenation of matrices in array x_top(:,ONLY,:) eliminates the not used middle index and makes a normal M*N matrix                   
    // 2. change all '0' indicating p <= p_level to 'inf'
    X3d(~X3d) = 100;   
    // 3. select worst points as minimum in each row of X  
    T_edge3d(:,1,l) = min( X3d(:,:,l), 'c' );
    
    // "quality" for each object based on previously "selected"
    for i=1:N // this could be eliminated, but good for user experience: user can define the sum_function in form of e.g. x(1)+x(2)+.. instead of having to write x(1,:)+x(2,:)+.. 
        edgeQuality1d(i) = sum_function(T_edge3d(:,1,i));
    end
    
   // print(%io(2),X3d); 
   // pause
    
    //print(%io(2),T_edge3d(:,:)); pause;
    
    // if more than K objects have edgeQuality not worse than edgeQuality(l), then P(l) > p_level
    // 'sum' here only counts 'trues' in (s_top_x > s_top_x(l)) statement 
    Pi_l = sum( (edgeQuality1d > edgeQuality1d(l)) );
    if Pi_l >=  K  
        answer = %T;
    else
        answer = %F;
    end
       
endfunction
// ===================
// return value is a scalar!
function  [ P_loser ] = lptFindPLoser(poss_init, qLoser, qSelSize, sum_function)
    // dichotomy until |dP| < eps_p, the latter initialized in loader.sce
    // "precise" (case eps_p < 0) is based on statement: every P() has a value present in 'poss_init'
    AllPossValues = unique(poss_init); 
    p_cur = [min(AllPossValues) 1]; 
 // p_cur=[0 1] works incorrectly if min(poss_init) > 0 (francly, it should NOT be > 0) 
    p_step =0.5*(p_cur(2)-p_cur(1));
   
    while ( 1 )
         // exit conditions
        if( PT_EPS_P < 0 )  
            
            index1d = find(AllPossValues >= p_cur(1) & AllPossValues <= p_cur(2));
           /// for debug use: 
           /// mprintf("Fuck!");             
           /// print(%io(2),length(lindex1d) );
           /// if( length(lindex1d) == 0 ) then pause; end;
                
            if( length(index1d) == 1 ) 
                P_loser = AllPossValues(index1d);
                break;
            end//if    
        else 
            if( p_step < PT_EPS_P ) 
                P_loser = (p_cur(1)+p_cur(2))/2;
                break;
            end//if      
        end//if
        
        // main test
        if lptDichotomyPLoser(poss_init, p_cur(1)+p_step, qLoser, qSelSize, sum_function)
            // +1/2 of current step
            p_cur(1) = p_cur(1) + p_step;
            p_step = 0.5 * p_step;        
        else
            // -1/2 of current step
            p_cur(2) = p_cur(2) - p_step;
            p_step = 0.5 * p_step;
        end//if
 
    end//while
endfunction
//===============
function sOut = lptParseQualFun( sIn );
    sOut = sIn; // todo:!
endfunction
// ==eof===eof==
