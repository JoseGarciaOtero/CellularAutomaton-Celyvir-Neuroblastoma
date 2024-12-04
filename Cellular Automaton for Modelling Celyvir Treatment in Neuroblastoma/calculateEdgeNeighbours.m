% This function is only used to calculate the neighbours of edge cells
function neighbours = calculateEdgeNeighbours(cellMatrix, row, column, neighbourhoodSize)

    % Grid size
    [rows, columns] = size(cellMatrix);

    % Initialise an array to store the types of neighbours
    neighbours = [];

    % Calculate the neighbourhood radius (half the size of the cell)
%     radius = floor(cell_size / 2);

    %% Check edges without corners

    % Check if the cell is on the top edge but not on the right or left side of the grid
    if row == 1 && column ~= 1 && column ~= columns
        start_row = row;   
        start_column = column - neighbourhoodSize;
        end_row = row + neighbourhoodSize;
        end_column = column + neighbourhoodSize;

        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(row + neighbourhoodSize - 1:end, :)];        
        submatrix2 = [submatrix(1:end - neighbourhoodSize, 1:neighbourhoodSize); submatrix(1:end - neighbourhoodSize, end - neighbourhoodSize + 1:end)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

    % Check if the cell is on the bottom edge but not on the right or left side of the grid
    if row == rows && column ~= 1 && column ~= columns
        start_row = row - neighbourhoodSize;   
        start_column = column - neighbourhoodSize;
        end_row = row;
        end_column = column + neighbourhoodSize;

        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(1:neighbourhoodSize, :)];        
        submatrix2 = [submatrix(neighbourhoodSize + 1:end, 1:neighbourhoodSize); submatrix(neighbourhoodSize + 1:end, end - neighbourhoodSize + 1:end)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

    % Check if the cell is on the left edge but not on the top or bottom of the grid
    if column == 1 && row ~= 1 && row ~= rows
        start_row = row - neighbourhoodSize;   
        start_column = column;
        end_row = row + neighbourhoodSize;
        end_column = column + neighbourhoodSize;
   
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(1:neighbourhoodSize, :); submatrix(end - neighbourhoodSize - 1:end, :)];        
        submatrix2 = [submatrix(neighbourhoodSize + 1:end - neighbourhoodSize, end - neighbourhoodSize + 1:end)];     
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

    % Check if the cell is on the right edge but not on the top or bottom of the grid
    if column == columns && row ~= 1 && row ~= rows 
        start_row = row - neighbourhoodSize;   
        start_column = column - neighbourhoodSize;
        end_row = row + neighbourhoodSize;
        end_column = column;
                
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(1:neighbourhoodSize, :); submatrix(end - neighbourhoodSize + 1:end, :)];       
        submatrix2 = [submatrix(neighbourhoodSize + 1:end - neighbourhoodSize, 1:neighbourhoodSize)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

    %% Check corners

    % If the cell is in the top-left corner
    if row == 1 && column == 1 
        start_row = row;   
        start_column = column;
        end_row = row + neighbourhoodSize;
        end_column = column + neighbourhoodSize; 
                
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(:, end - neighbourhoodSize + 1:end)];        
        submatrix2 = [submatrix(end - neighbourhoodSize + 1:end, 1:neighbourhoodSize)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end
    
    % If the cell is in the top-right corner
    if row == 1 && column == columns
        start_row = row;   
        start_column = column - neighbourhoodSize;
        end_row = row + neighbourhoodSize;
        end_column = column;          
                
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(:, 1:neighbourhoodSize)];        
        submatrix2 = [submatrix(end - neighbourhoodSize + 1:end, end - neighbourhoodSize + 1:end)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end
    
    % If the cell is in the bottom-left corner
    if row == rows && column == 1
        start_row = row - neighbourhoodSize;   
        start_column = column;
        end_row = row;
        end_column = column + neighbourhoodSize;
               
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(:, end - neighbourhoodSize + 1:end)];        
        submatrix2 = [submatrix(1:neighbourhoodSize, 1:neighbourhoodSize)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

    % If the cell is in the bottom-right corner
    if row == rows && column == columns
        start_row = row - neighbourhoodSize;   
        start_column = column - neighbourhoodSize;
        end_row = row;
        end_column = column; 
                
        start_row = max(start_row, 1);
        start_column = max(start_column, 1);
        end_row = min(end_row, rows);
        end_column = min(end_column, columns);

        % Extract the neighbourhood submatrix        
        submatrix = cellMatrix(start_row:end_row, start_column:end_column);       
        submatrix1 = [submatrix(:, 1:neighbourhoodSize)];        
        submatrix2 = [submatrix(1:neighbourhoodSize, neighbourhoodSize + 1:end)];       
        submatrix = [submatrix1(:); submatrix2(:)]; 
        neighbours = submatrix';
        return
    end

end
