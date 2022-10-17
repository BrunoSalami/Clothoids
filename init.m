function s = init()

    h = axes();

    s = nodes.Stretch(nodes.Clothoid(h, 1, 2, pi / 2, 10, 0, 0));
    s.append(5, 1 / 2);
    s.append(1, 0);
    s.append(5, 1 / 2);
    s.append(3, 0);
    s.append(7, 1 / 2);
    s.append(3, 0);
    s.append(1, 1 / 2);
    s.append(2, 1 / 4);

    axis equal;

end
