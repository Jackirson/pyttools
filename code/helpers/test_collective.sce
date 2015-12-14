
// Makes 2D joint poss-dist p(x,y) = min(px(x),py(y))
function p = makeJoint(px, py)
    lpx = length(px);
    lpy = length(py);
 
    if( lpx ~= lpy ) 
        error("Given distributions must be vectors of the same size.");
    end 
           
    p = min(meshgrid(px), meshgrid(py)')'; 
  
endfunction




// structure of p is [p1; p2; p3; p4], 
// where p1, p2 correspond to 1-st expert
//   and p3, p4 correspond to 2-nd expert 
function f = testColl(p, figurename)
    len = size(p,2);
    
    
    // way 1
    pex1 = makeJoint(p(1,:), p(2,:));
    pex2 = makeJoint(p(3,:), p(4,:));
    
    psup = ptSup(pex1(:)',pex2(:)');
    // make matrix
    psup = matrix(psup, len, len)
    
    // way 2
    pex1b = [p(1,:) p(2,:)];
    pex2b = [p(3,:) p(4,:)];
    
    pwgm = ptSup(pex1b,pex2b);
    pwg1 = pwgm(1:len);      // 1st object
    pwg2 = pwgm(len+1:2*len); // 2nd object
    
    pwg = makeJoint(pwg1, pwg2);
    
     f = 0; 
    // test 11 (if not pex1 < pwg)
    if( ptPrecise(pex1(:), pwg(:)) ~= 0 )
        f = f+11;
    end

    // test 12 (if not pex2 < pwg)
    if( ptPrecise(pex2(:), pwg(:)) ~= 0 )
        f = f+12;
    end    
    
    // test 10 (if not psup < pwg)
    if( ptPrecise(psup(:), pwg(:)) ~= 0 ) 
        f = f+10;
    end
    
    // plot joint dists at input (pex1,pex2) -- upper row 
    // and at output (psup, pwg) -- lower row
  //  fig = figure("background", -2, "figure_name", figurename);
   // subplot(2,2,1);
   // surf(pex1,"o");
   // subplot(2,2,2);
  //  surf(pex2);
  //  subplot(2,2,3);
  //  surf(psup);
  //  subplot(2,2,4);
  //  surf(pwg);
    
    fig2 = figure("background", -2, "figure_name", figurename);
    xdata = 1:len;
    ydata = 1:len;
    [xx,yy] = meshgrid(xdata, ydata);
    fontsize = 4.5;   
   
    subplot(2,2,1);
    plot3d3(xx, yy,pex1);
    xlabel("$x$", "font_size", fontsize);
    ylabel("$y$", "font_size", fontsize);
    zlabel("$\mathrm{p}_1$", "font_size", fontsize);
    
    subplot(2,2,2);
    plot3d3(xx, yy,pex2);   
    xlabel("$x$", "font_size", fontsize+0.5);
    ylabel("$y$", "font_size", fontsize+0.5);
    zlabel("$\mathrm{p}_2$", "font_size", fontsize);
        
    subplot(2,2,3);
    plot3d3(xx, yy,psup);
    xlabel("$x$", "font_size", fontsize+0.5);
    ylabel("$y$", "font_size", fontsize+0.5);
    zlabel("$\mathrm{p}$", "font_size", fontsize);
        
    subplot(2,2,4);
    plot3d3(xx, yy,pwg);
    xlabel("$x$", "font_size", fontsize+0.5);
    ylabel("$y$", "font_size", fontsize+0.5);
    zlabel("$\check{\mathrm{p}}$", "font_size", fontsize);    
    //disp(fig2);
    for j=1:length(fig2.children)
        axes = fig2.children(j);
        compound = axes.children(1); // first compound
    
        
    
        axes.rotation_angles = [100,220];
        axes.auto_scale = 'off';    
        axes.data_bounds = [0.8, 0.8, -0.2; len+0.2, len+0.2, 1.2];
     //   axes.axes_visible = ['off','off','off'];
        axes.box = 'off';
    
        for  i=1:length(compound.children)
           curve = compound.children(i);
           curve.foreground = 33;
           curve.thickness = 2;
          // if(j==1 & i==1)
          //       disp(curve);
          // end
        end
        
        compound = axes.children(2); // second compound
        for  i=1:length(compound.children)
           curve = compound.children(i);
           curve.foreground = 33;
           curve.thickness = 2;
           curve.mark_mode = 'on';
           curve.mark_style = 4; 
        end
       
    end   
endfunction




// msprintf("test%02d", 1)
