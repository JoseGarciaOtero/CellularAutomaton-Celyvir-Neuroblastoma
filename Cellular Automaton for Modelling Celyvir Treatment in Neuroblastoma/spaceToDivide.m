% Function to find positions where division is possible, also considering
% whether this cell is at the border or not. It returns the position,
% by rows and columns (i.e., [1,2;3,4...]) of the central cell of the cell where
% it will replicate. Therefore, row 1, column 2 is the central cell of the new
% cell.

function divisionPositions = spaceToDivide(cellMatrix, row, column, tumour_size)
    [rows, columns] = size(cellMatrix);
    
    % Size of the daughter cell (3x3)
    daughter_size = tumour_size;

    % Initialise the division positions matrix
    divisionPositions = [];
%     radius = floor(tumour_size/2);

    % Calculate the limits to search for space to divide
    % only the possible central cells will be considered.
    min_row = max(row - daughter_size, 1);
    max_row = min(row + daughter_size, rows);
    min_column = max(column - daughter_size, 1);
    max_column = min(column + daughter_size, columns);

    % Scan the space around the cell to find space to divide
    for i = min_row:max_row
        for j = min_column:max_column
            % Check if the cell does not exceed the matrix and is empty
            if isequal(cellMatrix(i, j), zeros(daughter_size))
                divisionPositions = [divisionPositions; [i,j]];
            end
        end
    end
end

