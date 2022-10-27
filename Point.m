classdef Point < handle

    properties

        x_offset
        y_offset
        hPoint

    end

    methods

        function obj = Point(varargin)

            obj.hPoint = plot(varargin{:}, 'ButtonDownFcn', @obj.grab);

        end

        function grab(obj, ~, ~)

            [x, y] = obj.get_cursor();
            obj.x_offset = get(obj.hPoint, 'XData') - x;
            obj.y_offset = get(obj.hPoint, 'YData') - y;

            set(gcf, ...
                'WindowButtonMotionFcn', @obj.move, ...
                'WindowButtonUpFcn', @obj.drop);

        end

        function move(obj, ~, ~)

            [x, y] = obj.get_cursor();
            set(obj.hPoint, ...
                'XData', x + obj.x_offset, ...
                'YData', y + obj.y_offset);

        end

    end

    methods (Static)

        function drop(~, ~)

            set(gcf, ...
                'WindowButtonMotionFcn', '', ...
                'WindowButtonUpFcn', '');

        end

        function [x, y] = get_cursor()

            cursor = get(gca, 'CurrentPoint');
            x = cursor(1);
            y = cursor(3);

        end

    end

end
