function cellMatrix = reactivateDeactivatedImmuneCells(cellMatrix, tumourDeaths, tumourSize, surroundingSize)
    [rows, columns] = size(cellMatrix);
    radius = floor(tumourSize / 2);
    % Iterate only over the dead tumour cells
    [death_i, death_j] = find(tumourDeaths);
    for k = 1:numel(death_i)
        i = death_i(k);
        j = death_j(k);         
        % Define the search area limits for immune cells
        start_i = max(i - radius - surroundingSize, 1);
        end_i = min(i + radius + surroundingSize, rows);
        start_j = max(j - radius - surroundingSize, 1);
        end_j = min(j + radius + surroundingSize, columns);
        % Search for deactivated immune cells in the area around the dead tumour cell
        [immune_i, immune_j] = find(cellMatrix(start_i:end_i, start_j:end_j) == 4);      
        for m = 1:numel(immune_i)        
            row = start_i + immune_i(m) - 1;           
            column = start_j + immune_j(m) - 1;               
            cellMatrix(row, column) = 3;
        end
    end
end

