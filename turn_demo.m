figure( ...
       'Units', 'normalized', ...
       'Position', [0, 0, 1, 1]);

h = axes( ...
         'NextPlot', 'Add', ...
         'DataAspectRatio', [1, 1, 1], ...
         'PlotBoxAspectRatio', [1, 1, 1]);
hold on;
xlim([-12, 12]);
ylim([-12, 12]);

cps = [ ...
       Point(-5, -5, 'o'), ...
       Point(5, -5, 'o'), ...
       Point(5, 5, 'o'), ...
       Point(-5, 5, 'o')];

t1 = nodes.Turn(h, cps(1:3));
t2 = nodes.Turn(h, cps(2:4));
t3 = nodes.Turn(h, cps([3, 4, 1]));
t4 = nodes.Turn(h, cps([4, 1, 2]));
