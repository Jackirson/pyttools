

function test_norm(Fun, qlenX, qXmax)

    x = ones(1, qlenX)*qXmax;
    
    f1 = (Fun(x)==qXmax);
    f2 = %T;
    f3 = %T;
    if f1 & f2 & f3 then
        mprintf("PASS\n");
    else
        mprintf("FAIL: f1:%d f2:%d f3:%d\n", uint16(f1), uint16(f2), uint16(f3));
    end
endfunction

// this is function f() unparsed
// ============== edit only this =========
qParam = 16;
qXmax = 10;
str = "y = 1/3000*( 0.25*(x(1)+0.1*x(3)*x(4)+x(5)+0.5*(x(2)+x(6))) + 0.05*(x(7)+x(9))*x(8) + 0.5*(x(10)+0.5*(x(11)+x(12))) ) * x(13)*x(16)*0.5*(x(14)+x(15))";
// ========================================

// make lambda
deff('y=qualFun(x)', str);

// test norm of function
test_norm(qualFun, qParam);

// make bars indicating f() growth with x1..xN increase
barX = 1:qParam;
barY = ones(qParam, 2);
for i=1:qParam
    x = ones(1, qParam)*qXmax;
    x(i) = 5;
    qual1 = qualFun(x);
    x(i) = 0;
    qual2 = qualFun(x);
    
    barY(i, 1) = 10-qual1;
    barY(i, 2) = 10-qual2;
end;
bar(barX, barY);



