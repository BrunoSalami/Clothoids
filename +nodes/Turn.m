classdef Turn < handle

    properties (Access = private)

        cps
        segments
        hline
        settings = struct( ...
                          'turn_radius', 2, ...
                          'relative_arc_length', .5, ...
                          'relative_entry_length', .5)

    end

    properties (Dependent)

        rel_entry_len
        rel_arc_len
        rel_exit_len

    end

    methods

        function obj = Turn(h_axis, cps)

            assert(isa(cps, 'Point'));
            assert(numel(cps) == 3);
            obj.cps = cps;

            obj.hline = line(nan, nan, ...
                             'Color', ones(1, 3) * .8, ...
                             'LineStyle', '--', ...
                             'PickableParts', 'none');

            n = obj.get_n(1);
            obj.segments = ...
                nodes.Clothoid(h_axis, obj.cps(1).x, obj.cps(1).y, atan2(n(2), n(1)), 0, ...
                               'HeadingChange', 0, 'FinalCurvature', 0). ...
                append('HeadingChange', 0, 'FinalCurvature', 0). ...
                append('HeadingChange', 0, 'FinalCurvature', 0). ...
                chain();

            addlistener(obj.cps, 'moving', @obj.cps_changed);

            notify(obj.cps, 'moving');

        end

    end

    methods (Access = private)

        function cps_changed(obj, ~, ~)

            n1 = obj.get_n(1);
            n2 = obj.get_n(2);

            dotp = n1(1) * n2(1) + n1(2) * n2(2);
            detp = n1(1) * n2(2) - n1(2) * n2(1);
            heading_change = atan2(detp, dotp);
            obj.settings.turn_radius = 2 / heading_change;
            max_curvature = 1 / obj.settings.turn_radius;

            % 1st clothoid
            obj.segments(1).x = obj.cps(1).x;
            obj.segments(1).y = obj.cps(1).y;
            obj.segments(1).psi = atan2(n1(2), n1(1));
            obj.segments(1).constraints = struct( ...
                                                 'HeadingChange', heading_change * obj.rel_entry_len, ...
                                                 'FinalCurvature', max_curvature);
            obj.segments(1).constrain();
            obj.segments(1).changed();

            % 2nd clothoid
            obj.segments(2).constraints = struct( ...
                                                 'HeadingChange', heading_change * obj.settings.relative_arc_length, ...
                                                 'FinalCurvature', max_curvature);
            obj.segments(2).constrain();
            obj.segments(2).changed();

            % 3rd clothoid
            obj.segments(3).constraints = struct( ...
                                                 'HeadingChange', heading_change * obj.rel_exit_len, ...
                                                 'FinalCurvature', 0);
            obj.segments(3).constrain();
            obj.segments(3).changed();

            % 1st correction
            b = [obj.segments(3).qx(end) - obj.cps(2).x; ...
                 obj.segments(3).qy(end) - obj.cps(2).y];
            A = [-n1(1), n2(1); ...
                 -n1(2), n2(2)];
            lambdas = A \ b;
            obj.segments(1).x = obj.segments(1).x + lambdas(1) * n1(1);
            obj.segments(1).y = obj.segments(1).y + lambdas(1) * n1(2);
            obj.segments(1).changed();

            % helper line
            set(obj.hline, ...
                'XData', [obj.cps(1:2).x], ...
                'YData', [obj.cps(1:2).y]);

        end

        function [n, len] = get_n(obj, i)

            [n, len] = get_normvec(obj.cps(i).x, ...
                                   obj.cps(i).y, ...
                                   obj.cps(i + 1).x, ...
                                   obj.cps(i + 1).y);

        end

    end

    methods

        function value = get.rel_entry_len(obj)

            value = (1 - obj.settings.relative_arc_length) * obj.settings.relative_entry_length;

        end

        function value = get.rel_exit_len(obj)

            value = (1 - obj.settings.relative_arc_length) * (1 - obj.settings.relative_entry_length);

        end

    end

end

function [n, len] = get_normvec(x1, y1, x2, y2)

    dx = x2 - x1;
    dy = y2 - y1;
    len = sqrt(dx^2 + dy^2);

    n = [dx; dy] / len;

end
