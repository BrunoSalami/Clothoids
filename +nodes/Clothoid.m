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
        qpsi
        qx
        qy

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

            obj.update();

        end

        function update(obj)

            set(obj.gobj, ...
                'XData', obj.qx, ...
                'YData', obj.qy);

        end

        function [x, y, psi, kappa, h] = tip(obj)

            psi = obj.qpsi(end);
            x = obj.qx(end);
            y = obj.qy(end);
            kappa = obj.kappa_end;
            h = obj.gobj.Parent;

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

        function value = get.qpsi(obj)

            value = polyval(obj.poly_psi, linspace(0, obj.len, obj.SAMPLES));

        end

        function value = get.qx(obj)

            value = cumtrapz(cos(obj.qpsi)) * obj.delta_s + obj.x;

        end

        function value = get.qy(obj)

            value = cumtrapz(sin(obj.qpsi)) * obj.delta_s + obj.y;

        end

    end

end
