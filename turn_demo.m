addpath external/structprompt/gedit;
figure( ...
       'Units', 'normalized', ...
       'Position', [0, 0, 1, 1]);

h = axes( ...
         'NextPlot', 'Add', ...
         'DataAspectRatio', [1, 1, 1], ...
         'PlotBoxAspectRatio', [1, 1, 1]);
hold on;
R = 10;
xlim([-1, 1] * R * 1.5);
ylim([-1, 1] * R * 1.5);

cps = arrayfun(@(alpha) Point(R * cos(alpha), R * sin(alpha), 'o'), (0:45:359) / 180 * pi);
% cps = arrayfun(@(alpha) Point(R * rand(), R * rand(), 'o'), 1:10);

for i = 0:numel(cps) - 1
    nodes.Turn(h, cps(mod(i + (0:2), numel(cps)) + 1));
end
