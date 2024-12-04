% This function will be used to make the mesenchymal cells
% attracted to the tumour cells with a probability x, as long as
% there is space for them to move and get closer. It will return two
% matrices represented by the word "death", which will be the matrix 
% that indicates the cells that are moving, so the place they occupied 
% becomes empty, and then we have the matrix "newCells" which represents 
% where the new cells are placed.

function [death,newCells] = moveCells(cellMatrix, tumourCells, cellSize, numPositions)
    [rows, columns] = size(cellMatrix);
    % Initialise the new cell matrix
    death = false(size(cellMatrix));
    newCells = false(size(cellMatrix));
    % Iterate over all cells
    for row = 1:rows
        for col = 1:columns
            if cellMatrix(row, col) == 2
                
                    % Evaluate attraction towards tumour cells, first check
                    % if there are tumour cells in their neighbourhood, 
                    % because if there are, they do not need to move, 
                    % or we check if there is space for them to move, 
                    % that is, if we see that there is no empty cell around, 
                    % we do not attempt to move
                    neighbours = calculateNeighbours(cellMatrix, row, col, 1);
                    emptySpace = sum(neighbours(:) == 0);
                    % Move mesenchymal cells
                    if emptySpace >= cellSize && ~any(neighbours(:) == 1)
        
                        nearestTumour = calculateNearestTumour(row, col, tumourCells);
                        position = calculateNewPosition(cellMatrix, row, col, nearestTumour, numPositions);

                        newCells(position(1), position(2)) = true;
                        % Mark the area as dead
                        death(row, col) = true;
                    end             
                
            end
            
        end
        
    end
   
end
