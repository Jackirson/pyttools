function set_axis_props()
    a = gca();
    a.data_bounds(1, 2) = 0;
    a.data_bounds(2, 2) = 1;
    a.tight_limits="on";
    a.auto_ticks = ["off", "off", "off"];
endfunction

function open_new_figure()
    figure("background", -2);
endfunction

function draw_sup(p1, p2)
    open_new_figure();
    subplot(3, 1, 1);
    plot(p1, "linewidth", 3);
    set_axis_props();
    ylabel("$\mathrm{p}_1$", "font_size", 4);
    subplot(3, 1, 2);
    plot(p2, "linewidth", 3);
    set_axis_props();
    ylabel("$\mathrm{p}_2$", "font_size", 4);
    subplot(3, 1, 3);
    plot(ptSup(p1, p2), "linewidth", 3);
    set_axis_props();
    ylabel("$\mathrm{p}_1\vee\mathrm{p}_2$", "font_size", 4);
endfunction

function test01()
    x = linspace(-3, 3, 100);
    p1 = exp(-(x-1).^2);
    p2 = exp(-(x+1).^2);
    draw_sup(p1, p2);
endfunction

function test02()
    sigma = 0.3;
    x = linspace(-3, 3, 5000);
    p1 = exp(-(x-1).^2 / (2 * sigma^2));
    p1(p1 < 0.1) = 0;
    p2 = exp(-(x+1).^2 / (2 * sigma^2));
    p2(p2 < 0.1) = 0;
    draw_sup(p1, p2);
endfunction

function test03()
    p1 = [0, 1/3, 2/3, 1, 2/3, 2/3, 2/3, 2/3, 1/3, 0];
    p2 = p1($ : -1 : 1);
    draw_sup(p1, p2);
endfunction

function test04()
    x = linspace(-3, 3, 100);
    p1 = 2 * exp(-x.^2);
    p1(p1 > 1) = 1;
    p2 = exp(-x.^2);
    draw_sup(p1, p2);
endfunction

function test05()
    x = linspace(-3, 3, 100);
    p1 = 3 * exp(-(x+1).^2) + exp(-(x-1).^2);
    p1 = p1 / max(p1);
    p2 = exp(-(x+1).^2);
    draw_sup(p1, p2);
    draw_sup(p2, p1);
endfunction

tests = 5;
for i = tests
    test_command = msprintf("test%02d();", i);
    execstr(test_command);
end
