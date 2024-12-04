function [death, newCells] = moveImmuneCells(cellsMatrix, tumourCells, tumourDeath, tumour_size, cell_size, surrounding_size, num_positions)
    [rows, columns] = size(cellsMatrix);
    death = false(size(cellsMatrix));
    newCells = false(size(cellsMatrix));
    radius = floor(tumour_size / 2);

    % Iterate over all tumour cells that have died
    for i = 1:rows
        for j = 1:columns
            if tumourDeath(i, j)
                neighbours = calculateNeighbours(cellsMatrix, i, j, surrounding_size);
                if any(neighbours(:) == 3)
                    % If there is an immunological cell, we delimit that space to
                    % find it faster.
                    start_row = max(i - radius - surrounding_size, 1);
                    end_row = min(i + radius + surrounding_size, rows);
                    start_column = max(j - radius - surrounding_size, 1);
                    end_column = min(j + radius + surrounding_size, columns);

                    for row = start_row:end_row
                        for column = start_column:end_column
                            % Check if it is an immunological cell and if it's the centre of
                            % the cell
                            if cellsMatrix(row, column) == 3
                                neighbours1 = calculateNeighbours(cellsMatrix, row, column, 1);

                                % Then calculate the neighbours to see if there is space to move,
                                % if not, we do not try. Also, check that there are no tumour neighbours.
                                empty_space = sum(neighbours1(:) == 0);

                                if empty_space >= cell_size && all(neighbours1 ~= 1)

                                    tumourDistance = calculateNearestTumour(row, column, tumourCells);
                                    position = calculateNewPosition(cellsMatrix, row, column, tumourDistance, num_positions);

                                    if cell_size == 1
                                        newCells(position(1), position(2)) = true;
                                        death(row, column) = true;
                                    else 
                                        start_row = max(position(1) - radius, 1);
                                        end_row = min(position(1) + radius, rows);
                                        start_column = max(position(2) - radius, 1);
                                        end_column = min(position(2) + radius, columns);
                                        newCells(start_row:end_row, start_column:end_column) = true;
                                        death(max(row - radius, 1):min(row + radius, rows), max(column - radius, 1):min(column + radius, columns)) = true;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end
