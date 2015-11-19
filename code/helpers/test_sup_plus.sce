
// load our test database and help functions
donttest = 1;
exec 'helpers/test_sup.sce';

// add new tests with more complexity
function poss = test101()
    x= linspace(-0.5, 7.5, 400);
    p1 = [zeros(x(x<0))  sin(x(x>=0 & x<=%pi))  zeros(x(x>%pi))];
    p2 = [zeros(x(x<%pi/4))  sin(2*(x(x>=%pi/4 & x<=3*%pi/4)-%pi/4))  zeros(x(x>3*%pi/4))];
    p3 = exp(-((x-4)/1.5).^2);
    p3(p3<0.05) = 0;
    poss = [p1; p2; p3];
endfunction

function poss = test102()
    x= linspace(-0.5, 7.5, 12);
    p1 = [zeros(x(x<0))  sin(x(x>=0 & x<=%pi))  zeros(x(x>%pi))];
    p2 = p1;
    p3 = exp(-((x-4)/1.5).^2);
    p3(p3<0.05) = 0;
    poss = [p1; p2; p3];
endfunction

function poss= test103()
    p1 = [0, 1/3, 2/3, 1, 2/3, 1/3, 1/3, 1/3, 1/3, 0];
    p2 = [0, 1/3, 2/3, 1, 2/3, 1/3, 1/3, 1/3, 1/3, 0];
    p3 = p1($ : -1 : 1);
    poss =[ p1; p2; p3 ];
endfunction

// input are ROWS of poss-dist (as ever)
// qMode == 0 -- no display
// qMode == 1 -- init poss in single plot
// qMode == 2 -- init poss in muliple plots
function [possCols] = draw_sup_plus(poss2d, qMode)
    f = figure("background", -2, "figure_name", "Compare Pref and Sup");
    if exists("f0") then
        f.figure_position(1) = f.figure_position(1) + f0.figure_size(1);
    end
    
    pmean = ptMeanStack(poss2d);
    psup  =  ptSupStack(poss2d);
    possCols = [poss2d; pmean; psup]'; 
    
    if( qMode == 0 )
        return;
    end
    
    if qMode == 1 
        qPlots = 3;
        subplot(qPlots, 1, 1);
        plot(poss2d', "linewidth", 3);
        set_axis_props();
        ylabel("$\mathrm{p}$", "font_size", 4);
    else
        qPlots = 2+size(poss2d,1);
        for i= 1:size(poss2d,1)
               subplot(qPlots, 1, i);
               plot(poss2d(i,:)', "linewidth", 3);
               set_axis_props();
               labeltext = msprintf("$p_%i$", i);
               ylabel(labeltext, "font_size", 4);
        end
    end
    
    
    // mean
    subplot(qPlots, 1, qPlots-1); 
    plot(pmean, "linewidth", 3);
    set_axis_props();
    ylabel("$\bar\mathrm{p}$", "font_size", 4);
    
    // sup
    subplot(qPlots, 1, qPlots);
    plot(psup, "linewidth", 3);
    set_axis_props();
    ylabel("$\check\mathrm{p}$", "font_size", 4);
    
endfunction                 

// Finally, the test
for testno = [102]
    test_command = msprintf("p = draw_sup_plus(test%02d(),2);", testno);
    execstr(test_command);
end
