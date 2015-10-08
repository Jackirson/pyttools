
// load functions
//exec loader.sce;

// load data
pp = ptLoadPoss3d( filename );
[qParam, qXmax, qObj] = size( pp );
xx = 1:qXmax;

//for j=1:qObj
page = 15;
clf();
subplot(qParam+1, 1, 2)
//a = gca();
title(strcat(["Techn. " string(page)]));

for i=1:qParam
     subplot(qParam+1, 1, i+1)
     plot(xx, pp(i,:,page))
     a = gca();
     set(a,"grid",[1 0]);
     a.box = "off";
     a.x_ticks.labels = "";
      a.y_ticks.labels = "";
     a.children.children(1).thickness = 2;  
end

//end
