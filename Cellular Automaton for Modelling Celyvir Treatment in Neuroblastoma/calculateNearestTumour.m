% This function returns the position of the closest central tumour cell 
% to the cell at (row, column). The input parameters row and column define its centre.

function position = calculateNearestTumour(row, column, tumourCells)
    [rows, columns] = size(tumourCells);

    % Initialise variables
    minimumDistance = Inf;
    position = [];

    % Iterate through the positions of tumour cells
    for i = 1:rows
        for j = 1:columns
            % Check if it is a tumour cell
            if tumourCells(i, j)
                % Calculate the Euclidean distance
                distance = sqrt((row - i)^2 + (column - j)^2);

                % Update if the current distance is smaller
                if distance < minimumDistance
                    minimumDistance = distance;
                    position = [i, j];
                end 
            end
        end
    end
end
