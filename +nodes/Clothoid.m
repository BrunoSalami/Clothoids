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

        previous
        next

    end

    properties (Access = private)

        gxobj

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

        function obj = Clothoid(h, x, y, psi, kappa_start, varargin)

            obj.x = x;
            obj.y = y;
            obj.psi = psi;
            obj.kappa_start = kappa_start;
            obj.constrain(varargin{:});

            obj.previous = nodes.Clothoid.empty();
            obj.next = nodes.Clothoid.empty();

            obj.init_graphics(h);

        end

        %% chain

        function new = insert(obj, len)

            new = nodes.Clothoid(obj.gxobj.Parent, obj.x, obj.y, obj.psi, obj.kappa_start, ...
                                 'Length', len, ...
                                 'FinalCurvature', obj.kappa_start);

            obj.link(obj.previous, new);
            obj.link(new, obj);

        end

        function new = append(obj, varargin)

            assert(isempty(obj.next));
            [x0, y0, psi0, kappa0, h] = obj.tip();
            new = nodes.Clothoid(h, x0, y0, psi0, kappa0, varargin{:});
            obj.link(obj, new);

        end

        function delete(obj)

            obj.link(obj.previous, obj.next);
            delete(obj.gxobj);

        end

        %% shape constrains

        function constrain(obj, varargin)

            constrains = get_constrains(varargin{:});

            if isempty(constrains.Length)
                obj.kappa_end = constrains.FinalCurvature;
                obj.len = 2 * constrains.HeadingChange / (obj.kappa_end + obj.kappa_start);
            elseif isempty(constrains.FinalCurvature)
                obj.len = constrains.Length;
                obj.kappa_end = 2 * constrains.HeadingChange / obj.len - obj.kappa_start;
            elseif isempty(constrains.HeadingChange)
                obj.len = constrains.Length;
                obj.kappa_end = constrains.FinalCurvature;
            end

            obj.refresh_graphics();

        end

        %% evaluation

        function [x, y, psi, kappa, h] = tip(obj)

            psi = obj.qpsi(end);
            x = obj.qx(end);
            y = obj.qy(end);
            kappa = obj.kappa_end;
            h = obj.gxobj.Parent;

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

        %% graphics

        function init_graphics(obj, h)

            obj.gxobj = plot( ...
                             nan, nan, ...
                             'Parent', h, ...
                             'Marker', 'o', ...
                             'MarkerSize', 3, ...
                             'MarkerFaceColor', 'w', ...
                             'MarkerIndices', [1, obj.SAMPLES], ...
                             'UserData', obj, ...
                             'ButtonDownFcn', @obj.click);

            obj.refresh_graphics();

        end

        function refresh_graphics(obj)

            set(obj.gxobj, ...
                'XData', obj.qx, ...
                'YData', obj.qy);

        end

        %% interactive

        function click(obj, h, event)

            if event.Button == 1
                obj.edit(h, event);
            elseif event.Button == 3
                obj.delete();
            end

        end

        function edit(obj, h, event)

            editable.Origin_X = obj.x;
            editable.Origin_Y = obj.y;
            editable.Origin_Heading = obj.psi;
            editable.Length = obj.len;
            editable.Curvature_Start = obj.kappa_start;
            editable.Curvature_End = obj.kappa_end;

            obj.select();

            editable = gedit(editable, 'Name', 'Edit Clothoid').retrieve();

            obj.x = editable.Origin_X;
            obj.y = editable.Origin_Y;
            obj.psi = editable.Origin_Heading;
            obj.len = editable.Length;
            obj.kappa_start = editable.Curvature_Start;
            obj.kappa_end = editable.Curvature_End;

            obj.changed(); % todo: use listener

            pause(.45);

            obj.unselect();

        end

        function select(obj)

            set(obj.gxobj, 'LineWidth', 3);

        end

        function unselect(obj)

            set(obj.gxobj, 'LineWidth', 1);

        end

        %% chain propagations

        function changed(obj)

            obj.refresh_graphics();

            if ~isempty(obj.next)
                obj.next.origin(obj);
            end

        end

        function origin(obj, previous)

            % todo: use listener
            [x0, y0, psi0, kappa0, ~] = previous.tip();
            obj.x = x0;
            obj.y = y0;
            obj.psi = psi0;
            obj.kappa_start = kappa0;

            obj.changed();

        end

        function clothoid_chain = chain(obj)

            first = obj.get_first();
            clothoid_chain = first.get_next(nodes.Clothoid.empty());

        end

        function first = get_first(obj)

            if isempty(obj.previous)
                first = obj;
            else
                first = obj.previous.get_first();
            end

        end

        function last = get_last(obj)

            if isempty(obj.next)
                last = obj;
            else
                last = obj.next.get_last();
            end

        end

        function clothoid_chain = get_next(obj, clothoid_chain)

            clothoid_chain(end + 1) = obj;
            if ~isempty(obj.next)
                clothoid_chain = obj.next.get_next(clothoid_chain);
            end

        end

    end

    methods (Static)

        function link(obj1, obj2)

            if ~isempty(obj1)
                obj1.next = obj2;
            end

            if ~isempty(obj2)
                obj2.previous = obj1;
            end

            if ~isempty(obj1) && ~isempty(obj2)
                obj2.origin(obj1);
            end

        end

    end

end

function constrains = get_constrains(varargin)

    persistent parser
    if isempty(parser)
        parser = inputParser();
        parser.addParameter('Length', []);
        parser.addParameter('FinalCurvature', []);
        parser.addParameter('HeadingChange', []);
    end

    parser.parse(varargin{:});
    constrains = parser.Results;

end
