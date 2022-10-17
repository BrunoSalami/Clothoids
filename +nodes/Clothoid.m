classdef Clothoid < handle

    properties (Constant)

        SAMPLES = 100

    end

    properties

        x
        y
        psi
        len
        kappa_start
        kappa_end

    end

    properties (Access = private)

        gobj

    end

    properties (Dependent)

        delta_kappa
        poly_psi
        delta_s

    end

    methods

        function obj = Clothoid(h, x, y, psi, len, kappa_start, kappa_end, varargin)

            obj.gobj = line(nan, nan, 'Parent', h, varargin{:});
            obj.x = x;
            obj.y = y;
            obj.psi = psi;
            obj.len = len;
            obj.kappa_start = kappa_start;
            obj.kappa_end = kappa_end;

            obj.update()

        end

        function update(obj)

            qpsi = polyval(obj.poly_psi, linspace(0, obj.len, obj.SAMPLES));
            set(obj.gobj, ...
                'XData', cumtrapz(cos(qpsi)) * obj.delta_s + obj.x, ...
                'YData', cumtrapz(sin(qpsi)) * obj.delta_s + obj.y);

        end

        function coefs = get.poly_psi(obj)

            coefs = [.5 * obj.delta_kappa, ...
                     obj.kappa_start, ...
                     obj.psi];

        end

        function value = get.delta_kappa(obj)

            value = (obj.kappa_end - obj.kappa_start) / obj.len;

        end

        function value = get.delta_s(obj)

            value = obj.len / (obj.SAMPLES + 1);

        end

    end

end