% This function will decide if the cell has space to move
% and whether moving brings it closer to the tumour cell or not. It will return 
% the new position of the cell.

function position = calculateNewPosition(cellMatrix, row, column, tumourProxCell, num_positions)
    [rows, columns] = size(cellMatrix);
    % Initialise the new position with the current position
    new_row = row;
    new_column = column;
    
    % Calculate the direction towards the tumour
    direction_row = sign(tumourProxCell(1) - row);
    direction_column = sign(tumourProxCell(2) - column);
    
    % Move the cell in the appropriate direction the specified number of steps
    for i = 1:num_positions
        new_row = new_row + direction_row;
        new_column = new_column + direction_column;
        
        % Check if the new position is within the matrix bounds and is empty
        if new_row >= 1 && new_row <= rows && new_column >= 1 && new_column <= columns && cellMatrix(new_row, new_column) == 0
            % Update the cell's position
            row = new_row;
            column = new_column;
        else
            % If the new position is out of bounds or not empty, stop moving
            break;
        end
    end
    
    % Return the final position
    position = [row, column];
end


