function [death] = shouldDeactivatedImmuneDie(cellMatrix)

    % Create a logical matrix indicating whether each deactivated immune cell should die
    death = false(size(cellMatrix));

    % Iterate through all immune system cells
    [rows, columns] = size(cellMatrix);
    for row = 1:rows
        for column = 1:columns
           
            % Rule 1: Death of deactivated immune cells at 50%
            if cellMatrix(row, column) == 4 % If it is a deactivated immune cell
                death_probability = rand();
                if death_probability <= 0.1
                    death(row, column) = true;
                end
            end
        end
    end

end
