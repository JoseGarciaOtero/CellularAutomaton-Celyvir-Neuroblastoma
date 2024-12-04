function [death, conversion] = shouldTumourDie(cellMatrix, tumourCells, tumourSize, immuneSize)

    radius = floor(tumourSize/2);

    % Create a logical matrix indicating if each tumour cell should die
    death = false(size(cellMatrix));
    
    % Create a logical matrix indicating if each tumour cell should convert to mesenchymal
    conversion = false(size(cellMatrix));
    
    % Iterate through all tumour cells
    [rows, columns] = size(cellMatrix);
    for row = 1:rows
        for column = 1:columns
            if tumourCells(row, column) == 1
                % Ensure we do not check cells that have already been examined
                tumourCells(row, column) = false;
                
                % Calculate the neighbours of the tumour cell
                neighbours = calculateNeighbours(cellMatrix, row, column, 1);
                deathProbability = rand();
                
                % Rule 1: If a tumour cell is surrounded by a mesenchymal cell and at least one immune system cell, 80% probability of death
                if sum(neighbours(:) == 2) >= tumourSize && sum(neighbours(:) == 3) >= immuneSize && deathProbability <= 0.8
                    % >=6 because if it is surrounded by two mesenchymal cells converted from tumour cells, they form a 3x3 region.
                    % Mark all cells in the 3x3 region
                    startRow = max(row - radius, 1);
                    endRow = min(row + radius, rows);
                    startColumn = max(column - radius, 1);
                    endColumn = min(column + radius, columns);
                    death(startRow:endRow, startColumn:endColumn) = true;
                    conversion(startRow:endRow, startColumn:endColumn) = true;
                end
                
                % Rule 2: If a tumour cell is surrounded by a single immune system cell, 30% probability of death
                if sum(neighbours(:) == 3) == immuneSize && deathProbability <= 0.3
                    % Mark all cells in the 3x3 region
                    startRow = max(row - radius, 1);
                    endRow = min(row + radius, rows);
                    startColumn = max(column - radius, 1);
                    endColumn = min(column + radius, columns);
                    death(startRow:endRow, startColumn:endColumn) = true;
                end
                
                % Rule 3: If a tumour cell is surrounded by more than one immune system cell, 40% probability of death
                if sum(neighbours(:) == 3) > immuneSize && deathProbability <= 0.4
                    % Mark all cells in the 3x3 region
                    startRow = max(row - radius, 1);
                    endRow = min(row + radius, rows);
                    startColumn = max(column - radius, 1);
                    endColumn = min(column + radius, columns);
                    death(startRow:endRow, startColumn:endColumn) = true;
                end
                
                % Rule 4: If a tumour cell is surrounded by at least one mesenchymal cell and no immune cells, 20% probability of death
                if sum(neighbours(:) == 2) >= tumourSize && sum(neighbours(:) == 3) == 0 && deathProbability <= 0.2
                    % Mark all cells in the 3x3 region
                    startRow = max(row - radius, 1);
                    endRow = min(row + radius, rows);
                    startColumn = max(column - radius, 1);
                    endColumn = min(column + radius, columns);
                    death(startRow:endRow, startColumn:endColumn) = true;
                    conversion(startRow:endRow, startColumn:endColumn) = true;
                end
            end
        end
    end
end
