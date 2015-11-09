//=================================================
// Helper functions
//=================================================

function f = is_strictly_monotone_func(x, y)
    [x1, ind] = unique(x(:));
    y1 = y(ind);
    f1 = isequal(unique(y1), y1);
    [y1, ind] = unique(y(:));
    x1 = x(ind);
    f2 = isequal(unique(x1), x1);
    f = f1 & f2;
endfunction

function f = is_monotone_func(x, y)
    [x1, ind] = gsort(x(:));
    for x0 = x1'
        if length(unique(y(x == x0))) ~= 1 then
            f = %f;
            return;
        end
    end
    y1 = y(ind);
    f = isequal(gsort(y1), y1);
endfunction

function test_sup(p1, p2, psup1, psup2)
//    open_new_figure();
//    [tmp, ind] = gsort(p1);
//    plot(p1(ind), psup1(ind), "-o");
    
    f1 = is_strictly_monotone_func(psup1, psup2);
    f2 = is_monotone_func(p1(p1 > 0), psup1(p1 > 0));
    f3 = is_monotone_func(p2(p2 > 0), psup2(p2 > 0));
    if f1 & f2 & f3 then
        mprintf("PASS\n");
    else
        mprintf("FAIL: f1:%d f2:%d f3:%d\n", uint16(f1), uint16(f2), uint16(f3));
    end
endfunction

function set_axis_props()
    a = gca();
    a.data_bounds(1, 2) = 0;
    a.data_bounds(2, 2) = 1;
    a.tight_limits="on";
    a.auto_ticks = ["off", "off", "off"];
endfunction

function f = open_new_figure()
    f = figure("background", -2, "figure_name", msprintf("test%02d", testno));
endfunction

function [psup, f] = draw_sup(p1, p2, f0, var)
    f = open_new_figure();
    if exists("f0") & ~isempty(f0) then
        f.figure_position(1) = f.figure_position(1) + f0.figure_size(1);
    end
    if ~exists("var") then
        var = 1;
    end
    
    subplot(3, 1, 1);
    plot(p1, "linewidth", 3);
    set_axis_props();
    if var == 1 then
        ylabel("$\mathrm{p}_1$", "font_size", 4);
    else
        ylabel("$\mathrm{p}_2$", "font_size", 4);
    end
    subplot(3, 1, 2);
    plot(p2, "linewidth", 3);
    set_axis_props();
    if var == 1 then
        ylabel("$\mathrm{p}_2$", "font_size", 4);
    else
        ylabel("$\mathrm{p}_1$", "font_size", 4);
    end
    psup = ptSup(p1, p2);
    subplot(3, 1, 3);
    plot(psup, "linewidth", 3);
    set_axis_props();
    if var == 1 then
        ylabel("$\mathrm{p}_1\vee\mathrm{p}_2$", "font_size", 4);
    else
        ylabel("$\mathrm{p}_2\vee\mathrm{p}_1$", "font_size", 4);
    end
endfunction

//=================================================
// Tests
//=================================================

function test01()
    x = linspace(-3, 3, 100);
    p1 = exp(-(x-1).^2);
    p2 = exp(-(x+1).^2);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test02()
    sigma = 0.3;
    x = linspace(-3, 3, 100);
    p1 = exp(-(x-1).^2 / (2 * sigma^2));
    p1(p1 < 0.1) = 0;
    p2 = exp(-(x+1).^2 / (2 * sigma^2));
    p2(p2 < 0.1) = 0;
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test03()
    p1 = [0, 1/3, 2/3, 1, 2/3, 2/3, 2/3, 2/3, 1/3, 0];
    p2 = p1($ : -1 : 1);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test04()
    x = linspace(-3, 3, 100);
    p1 = 2 * exp(-x.^2);
    p1(p1 > 1) = 1;
    p2 = exp(-x.^2);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test05()
    x = linspace(0, 1, 50);
    p1 = x;
    p1(1) = p1(2);
    p2 = p1($ : -1 : 1);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test06()
    p1 = [0.1, 1, 1];
    p2 = [0.5, 1, 0.1];
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test07()
    p1 = [0 0 1 0 0];
    p2 = [0 1 1 0.5 0];
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test08()
    x = linspace(-1, 1, 100);
    p1 = 1 - abs(x);
    p2 = p1;
    p2(0.2 <= x & x <= 0.4) = max(p2(0.2 <= x & x <= 0.4));
    p2(0.6 <= x & x <= 0.8) = max(p2(0.6 <= x & x <= 0.8));
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test09()
    x = linspace(-3, 3, 500);
    p1 = 3 * exp(-(x+1).^2) + exp(-(x-1).^2);
    p1 = p1 / max(p1);
    p2 = exp(-(x+1).^2);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test10()
    x = linspace(-3, 3, 100);
    p1 = 3 * exp(-(x+1).^2) + exp(-(x-1).^2);
    p1 = p1 / max(p1);
    p2 = exp(-(x+1).^2);
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

function test11()
    p1 = [1, 0.8, 0.8, 0.8, 0.9, 0.4, 0.2, 0];
    p2 = [1, 0.8, 0.7, 0.6, 0.5, 0.4, 0.4, 0];
    [psup1, f] = draw_sup(p1, p2);
    psup2 = draw_sup(p2, p1, f, 2);
    test_sup(p1, p2, psup1, psup2);
endfunction

//=================================================
// Test execution
//=================================================

// Pay attantion to test10()!!! Its result is incorrect.

tests = 1 : 11;
for testno = tests
    test_command = msprintf("test%02d();", testno);
    mprintf("test%02d - ", testno);
    execstr(test_command);
end
