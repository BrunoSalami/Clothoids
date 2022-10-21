classdef init < handle

    properties

        current
        ax
        editor

    end

    methods

        function obj = init()

            obj.init_figure();
            obj.init_path();

        end

        function init_figure(obj)

            addpath(fullfile('external', 'structprompt', 'gedit'));

            tag = 'ClothoidOpt';
            f = findobj('tag', tag);
            if ~isempty(f)
                delete(f);
            end
            f = figure( ...
                       'Name', 'Clothoid Optimization', ...
                       'NumberTitle', 'Off', ...
                       'Tag', 'ClothoidOpt', ...
                       'Units', 'Pixel', ...
                       'Position', [100, 300, 820, 640]);

            p1 = uipanel( ...
                         'Parent', f, ...
                         'Units', 'Pixel', ...
                         'Position', [20, 20, 260, 600]);

            nav = [ ...
                   button(p1, 'Previous', @obj.previous), ...
                   button(p1, 'Next', @obj.next), ...
                   button(p1, 'Apply', @obj.apply)];
            align(nav, 'Fixed', 10, 'Bottom');

            lbls = [ ...
                    label(p1, 'origin x'), ...
                    label(p1, 'origin y'), ...
                    label(p1, 'origin heading'), ...
                    label(p1, 'length'), ...
                    label(p1, 'origin curvature'), ...
                    label(p1, 'final curvature')];
            align(lbls, 'Left', 'Fixed', 10);

            obj.editor.x = edit(p1, @obj.apply);
            obj.editor.y = edit(p1, @obj.apply);
            obj.editor.psi = edit(p1, @obj.apply);
            obj.editor.len = edit(p1, @obj.apply);
            obj.editor.kappa_start = edit(p1, @obj.apply);
            obj.editor.kappa_end = edit(p1, @obj.apply);
            align(struct2array(obj.editor), 'Left', 'Fixed', 10);

            obj.ax = axes( ...
                          'NextPlot', 'Add', ...
                          'DataAspectRatio', [1, 1, 1], ...
                          'Units', 'Pixel', ...
                          'Position', [300, 20, 500, 600]);

        end

        function init_path(obj)

            obj.current = ...
                nodes.Clothoid(obj.ax, 0, 0, 0, 0, 'Length', 10, 'HeadingChange', 0). ...
                append('FinalCurvature', 1 / 10, 'HeadingChange', pi / 6). ...
                append('FinalCurvature', 1 / 10, 'HeadingChange', pi / 6). ...
                append('FinalCurvature', 0, 'HeadingChange', pi / 6). ...
                append('FinalCurvature', 0, 'Length', 10). ...
                append('FinalCurvature', 1 / 10, 'HeadingChange', pi / 2). ...
                append('FinalCurvature', 1 / 10, 'HeadingChange', pi / 4). ...
                append('FinalCurvature', 0, 'HeadingChange', pi / 4). ...
                get_first();

            obj.focus();

        end

        function focus(obj)

            obj.current.select();
            set(obj.editor.x, 'String', num2str(obj.current.x));
            set(obj.editor.y, 'String', num2str(obj.current.y));
            set(obj.editor.psi, 'String', num2str(obj.current.psi));
            set(obj.editor.len, 'String', num2str(obj.current.len));
            set(obj.editor.kappa_start, 'String', num2str(obj.current.kappa_start));
            set(obj.editor.kappa_end, 'String', num2str(obj.current.kappa_end));

        end

        function previous(obj, h, event)

            obj.current.unselect();
            obj.current = obj.current.parent;
            obj.focus();

        end

        function next(obj, h, event)

            obj.current.unselect();
            obj.current = obj.current.child;
            obj.focus();

        end

        function apply(obj, h, event)

            obj.current.x = eval(get(obj.editor.x, 'String'));
            obj.current.y = eval(get(obj.editor.y, 'String'));
            obj.current.psi = eval(get(obj.editor.psi, 'String'));
            obj.current.len = eval(get(obj.editor.len, 'String'));
            obj.current.kappa_start = eval(get(obj.editor.kappa_start, 'String'));
            obj.current.kappa_end = eval(get(obj.editor.kappa_end, 'String'));
            obj.current.changed();

        end

    end

end

function h = button(p, str, cb, varargin)

    h = uicontrol( ...
                  'Parent', p, ...
                  'Style', 'PushButton', ...
                  'String', str, ...
                  'Position', [20, 20, 60, 35], ...
                  'Callback', cb, ...
                  varargin{:});

end

function h = label(p, lbl, varargin)

    h = uicontrol( ...
                  'Parent', p, ...
                  'Style', 'Text', ...
                  'String', lbl, ...
                  'Position', [20, 75, 130, 35], ...
                  'HorizontalAlignment', 'Right');

end

function h = edit(p, cb)

    h = uicontrol( ...
                  'Parent', p, ...
                  'Style', 'Edit', ...
                  'Position', [180, 75, 60, 35], ...
                  'Callback', cb);

end

function previous(h, e)

    disp(h);
    disp(e);

end
