function death = shouldMesenchymalDie(cellMatrix, immuneSize)
    % Creates a logical matrix indicating whether each mesenchymal cell should die
    death = false(size(cellMatrix));
    % Loops through all mesenchymal cells
    [rows, columns] = size(cellMatrix);
    for row = 1:rows
        for column = 1:columns
            if cellMatrix(row, column) == 2
                % Calculates the neighbours of the mesenchymal cell
                neighbours = calculateNeighbours(cellMatrix, row, column, 1);
                deathProbability = rand();

                % Rule 1: If a mesenchymal cell is surrounded by only one immune 
                % cell, the probability of dying is 40%. 
                % Rule 2: If a mesenchymal cell is surrounded solely by immune cells, 
                % the probability of death is 80%.
                if (sum(neighbours(:) == 2) == immuneSize || all(neighbours(:) == 3)) && deathProbability <= (0.4 + 0.4 * (sum(neighbours(:) == 2) > immuneSize))
                    death(row, column) = true;
                end
            end
        end
    end
end
