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
        pulling
        dropped

    end

    methods

        function obj = Point(varargin)

            obj.hPoint = plot(varargin{:}, 'ButtonDownFcn', @obj.grab);

        end

        function grab(obj, source, event)

            [cx, cy] = obj.get_cursor();
            obj.x_offset = get(obj.hPoint, 'XData') - cx;
            obj.y_offset = get(obj.hPoint, 'YData') - cy;

            if event.Button == 1

                set(gcf, ...
                    'WindowButtonMotionFcn', @obj.move, ...
                    'WindowButtonUpFcn', @obj.drop);

            elseif event.Button == 3

                set(gcf, ...
                    'WindowButtonMotionFcn', @obj.pull, ...
                    'WindowButtonUpFcn', @obj.drop);

            end

        end

        function move(obj, ~, ~)

            [cx, cy] = obj.get_cursor();
            set(obj.hPoint, ...
                'XData', cx + obj.x_offset, ...
                'YData', cy + obj.y_offset);

            obj.notify('moving');

        end

        function pull(obj, ~, ~)

            [cx, cy] = obj.get_cursor();
            xd = get(obj.hPoint, 'XData');
            yd = get(obj.hPoint, 'YData');
            event_data = nodes.event_data.PullEvent( ...
                                                    cx + obj.x_offset - xd, ...
                                                    cy + obj.y_offset - yd);

            obj.notify('pulling', event_data);

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
