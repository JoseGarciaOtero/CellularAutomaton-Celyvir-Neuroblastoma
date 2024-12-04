function death = shouldDeactivatedImmunological(cellMatrix)

    % Create a logical matrix indicating whether each immune system cell should die
    death = false(size(cellMatrix));

    % Iterate through all immune system cells
    [rows, columns] = size(cellMatrix);
    for row = 1:rows
        for column = 1:columns
            if cellMatrix(row, column) == 3
                % Calculate the neighbours of the immune system cell
                neighbours = calculateNeighbours(cellMatrix, row, column, 1);
                death_prob = rand();

                % Rule 1: If an immune system cell is surrounded by more
                % than one tumour cell, 80% probability of deactivation
                if sum(neighbours(:) == 1) > 1 && death_prob <= 0.8
                    death(row, column) = true;
                end
                
                % Rule 2: If an immune system cell is surrounded by a single
                % tumour cell, 60% probability of deactivation
                if sum(neighbours(:) == 1) == 1 && death_prob <= 0.6
                    death(row, column) = true;
                end
            end
        end
    end
end
