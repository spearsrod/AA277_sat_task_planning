function visited = stateVisited(s, V)
    visited = false;
    for i = 1:length(V)
        if s.t == V{i}.t && s.tp_s == V{i}.tp_s
            visited = true;
        end
    end
end