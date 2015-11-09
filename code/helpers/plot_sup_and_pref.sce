
function set_axis_props()
    a = gca();
    a.data_bounds(1, 2) = 0;
    a.data_bounds(2, 2) = 1;
    a.tight_limits="on";
    a.auto_ticks = ["off", "off", "off"];
endfunction

// input are ROWS of poss-dist (as ever)
function [f] = draw(poss2d)
    f = figure("background", -2, "figure_name", "Compare Pref and Sup");
    if exists("f0") then
        f.figure_position(1) = f.figure_position(1) + f0.figure_size(1);
    end
    
    subplot(3, 1, 1);
    plot(poss2d', "linewidth", 3);
    set_axis_props();
    ylabel("$\mathrm{p}$", "font_size", 4);
    subplot(3, 1, 2);
    
    // mean
    pmean = ptMeanStack(poss2d);
    plot(pmean, "linewidth", 3);
    set_axis_props();
    ylabel("$\hat\mathrm{p}$", "font_size", 4);
    
    // sup
    psup  =  ptSupStack(poss2d);
    subplot(3, 1, 3);
    plot(psup, "linewidth", 3);
    set_axis_props();
    ylabel("$\vee\mathrm{p}$", "font_size", 4);
endfunction

// Finally, the test
x= linspace(-0.5, 7.5, 400);
p1 = [zeros(x(x<0))  sin(x(x>=0 & x<=%pi))  zeros(x(x>%pi))];
p2 = [zeros(x(x<%pi/4))  sin(2*(x(x>=%pi/4 & x<=3*%pi/4)-%pi/4))  zeros(x(x>3*%pi/4))];
p3 = exp(-((x-4)/1.5).^2);
p3(p3<0.05) = 0;
poss = [p1; p2; p3];
draw(poss);
