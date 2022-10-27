classdef Point < handle

    properties

        x_offset
        y_offset
        hPoint
        x
        y

    end

    events

        moving
        dropped

    end

    methods

        function obj = Point(varargin)

            obj.hPoint = plot(varargin{:}, 'ButtonDownFcn', @obj.grab);

        end

        function grab(obj, ~, ~)

            [cx, cy] = obj.get_cursor();
            obj.x_offset = get(obj.hPoint, 'XData') - cx;
            obj.y_offset = get(obj.hPoint, 'YData') - cy;

            set(gcf, ...
                'WindowButtonMotionFcn', @obj.move, ...
                'WindowButtonUpFcn', @obj.drop);

        end

        function move(obj, ~, ~)

            [cx, cy] = obj.get_cursor();
            set(obj.hPoint, ...
                'XData', cx + obj.x_offset, ...
                'YData', cy + obj.y_offset);

            obj.notify('moving');

        end

        function drop(obj, ~, ~)

            set(gcf, ...
                'WindowButtonMotionFcn', '', ...
                'WindowButtonUpFcn', '');

            obj.notify('dropped');

        end

        function value = get.x(obj)

            value = get(obj.hPoint, 'XData');

        end

        function value = get.y(obj)

            value = get(obj.hPoint, 'YData');

        end

    end

    methods (Static)

        function [cx, cy] = get_cursor()

            cursor = get(gca, 'CurrentPoint');
            cx = cursor(1);
            cy = cursor(3);

        end

    end

end
