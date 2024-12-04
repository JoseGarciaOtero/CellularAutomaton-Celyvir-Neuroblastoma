function [i, j] = getRandomPositionWithSpace(cellMatrix)
    % Get a random position in the cellMatrix with enough space for a cell of size cellSize
    [rows, columns] = size(cellMatrix);

    while true
        i = randi(rows);
        j = randi(columns);

        % Check if the cell fits in the random position
        if cellMatrix(i, j) == 0
            break;
        end
    end
end
