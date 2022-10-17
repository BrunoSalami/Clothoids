classdef Stretch < handle

    properties (Access = private)

        segments = nodes.Clothoid.empty(4, 0)

    end

    methods

        function obj = Stretch(clothoid)

            if nargin > 0
                obj.init(clothoid);
            end

        end

        function init(obj, clothoid)

            assert(isempty(obj.segments));
            assert(isa(clothoid, 'nodes.Clothoid'));

            obj.segments(end + 1) = clothoid;

        end

        function append(obj, len, kappa_end)

            assert(~isempty(obj.segments));

            [x, y, psi, kappa, h] = obj.segments(end).tip();
            obj.segments(end + 1) = nodes.Clothoid(h, x, y, psi, len, kappa, kappa_end);

        end

    end

end
