%% This function generates two connected tumour cell cores

function [cellMatrix, numMesenchymalCells] = initialiseEnvironment1(rows, columns, tumourSize, mesenchymalSize, immunologicalSize)
    % Initialise the grid with empty cells
    cellMatrix = zeros(rows, columns);
    
    % Calculate the separation distance based on the tumour proportion
    totalSpace = rows * columns;
    tumourProportion = 0.0737; % We want the tumour to occupy [0.0737-0.2288] of the total space
    separationDistance = ceil(sqrt(totalSpace * tumourProportion) / 2);

    centreRow = ceil(rows / 2);
    centreColumn = ceil(columns / 2);
    
    % First seed cell at the centre
    cellMatrix(centreRow, centreColumn) = 1;
    
    % Second seed cell at a specified distance
    direction = randi([0, 3]); % 0: right, 1: down, 2: left, 3: up
    
    switch direction
        case 0
            row2 = centreRow;
            column2 = centreColumn + separationDistance;
        case 1
            row2 = centreRow + separationDistance;
            column2 = centreColumn;
        case 2
            row2 = centreRow;
            column2 = centreColumn - separationDistance;
        case 3
            row2 = centreRow - separationDistance;
            column2 = centreColumn;
    end
    
    % Ensure the second seed cell is within the matrix bounds
    if row2 > 0 && row2 <= rows && column2 > 0 && column2 <= columns
        cellMatrix(row2, column2) = 1;
    else
        error('The second seed cell is out of matrix bounds.');
    end
    
    % Calculate how much space the tumour needs to occupy
    tumourSpace = round(totalSpace * tumourProportion);
    
    % Initialise variable to store the space occupied by the tumour
    occupiedTumourSpace = 2; % Initialised with the two seed cells
    
    % Grow the tumour until it occupies the desired space
    while occupiedTumourSpace < tumourSpace
        % Calculate cell division and update the matrix
        tumourCells = cellMatrix == 1;
        tumourDivision = calculateCellDivision(cellMatrix, tumourCells, tumourSize);
        cellMatrix(tumourDivision) = 1;
        % Update the occupied tumour space
        occupiedTumourSpace = sum(cellMatrix(:) == 1);
        %drawEnvironment(cellMatrix,0)
        %pause;
    end

    % Calculate the total available space, subtracting the tumour cell space
    totalSpace = sum(cellMatrix(:) == 0);

    % Determine how much space you want to occupy (from the total space) for mesenchymal cells
    mesenchymalProportion = round(totalSpace * 0.2829 * 0.4);
    % Calculate how many mesenchymal cells will fit in that space
    numMesenchymalCells = floor(mesenchymalProportion / mesenchymalSize^2);

    %% The idea is to occupy 1/6 of the available space after placing the tumour with immune cells, of which 5/6 have been deactivated and 1/6 remain active.
    %% Of the deactivated immune cells, 3/6 will be placed around the tumour, and the rest will be placed randomly 
    % Determine how much space you want to occupy with deactivated immune cells
    immunologicalProportion = round(tumourSpace / 2); 
    % Calculate how many deactivated immune cells will be placed in that space
    numDeactivatedImmuneCells = floor(immunologicalProportion * (5 / 6) / immunologicalSize^2);

    % Calculate how many deactivated immune cells will be placed around the tumour
    numDeactivatedImmuneCells_tumour = floor(numDeactivatedImmuneCells * (3 / 5));

    % Calculate how many deactivated immune cells will be placed randomly
    numDeactivatedImmuneCells_random = numDeactivatedImmuneCells - numDeactivatedImmuneCells_tumour;

    % Create a logical auxiliary matrix for valid positions of deactivated immune cells
    validPositionsMatrix = false(rows, columns);
    fixedRadius = 3;
    
    for i = 1:rows
        tumourColumnsInRow = find(cellMatrix(i, :) == 1);
        if ~isempty(tumourColumnsInRow)
            minColumn = min(tumourColumnsInRow);
            maxColumn = max(tumourColumnsInRow);
            
            % Minimum and maximum radius for the left and right parts of this row
            minRadiusLeft = minColumn - 1;
            maxRadiusLeft = minColumn - 1 - fixedRadius;
            
            minRadiusDown = maxColumn + 1;
            maxRadiusDown = maxColumn + 1 + fixedRadius;
    
            % Ensure the indices are within matrix bounds
            minRadiusLeft = max(minRadiusLeft, 1);
            maxRadiusLeft = max(maxRadiusLeft, 1);
            
            minRadiusDown = min(minRadiusDown, columns);
            maxRadiusDown = min(maxRadiusDown, columns);
    
            % Mark valid positions in the logical matrix
            validPositionsMatrix(i, maxRadiusLeft:minRadiusLeft) = true;
            validPositionsMatrix(i, minRadiusDown:maxRadiusDown) = true;
        end
    end

    for j = 1:columns
        tumourRowsInColumn = find(cellMatrix(:, j) == 1);
        if ~isempty(tumourRowsInColumn)
            minRow = min(tumourRowsInColumn);
            maxRow = max(tumourRowsInColumn);
            
            % Minimum and maximum radius for the left and right parts of this row
            minRadiusLeft = minRow - 1;
            maxRadiusLeft = minRow - 1 - fixedRadius;
            
            minRadiusDown = maxRow + 1;
            maxRadiusDown = maxRow + 1 + fixedRadius;
    
            % Ensure the indices are within matrix bounds
            minRadiusLeft = max(minRadiusLeft, 1);
            maxRadiusLeft = max(maxRadiusLeft, 1);
            
            minRadiusDown = min(minRadiusDown, columns);
            maxRadiusDown = min(maxRadiusDown, columns);
    
            % Mark valid positions in the logical matrix
            validPositionsMatrix(maxRadiusLeft:minRadiusLeft, j) = true;
            validPositionsMatrix(minRadiusDown:maxRadiusDown, j) = true;
        end
    end
    
    % Place deactivated immune cells randomly in valid positions
    validPositionIndices = find(validPositionsMatrix);
    numValidPositions = numel(validPositionIndices);
    
    while numDeactivatedImmuneCells_tumour > 0 && numValidPositions > 0
        idx = randi(numValidPositions);
        pos = validPositionIndices(idx);
        cellMatrix(pos) = 4; % Deactivated immune cells
        numDeactivatedImmuneCells_tumour = numDeactivatedImmuneCells_tumour - 1;
        % Remove the selected position from the valid positions list
        validPositionIndices(idx) = [];
        numValidPositions = numValidPositions - 1;
    end

    % Place mesenchymal cells randomly in positions with enough space
    for k = 1:numMesenchymalCells
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        if cellMatrix(i, j) == 0
            cellMatrix(i, j) = 0; % Mesenchymal cell
        end
    end

    % Place random deactivated immune cells
    for k = 1:numDeactivatedImmuneCells_random
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 4; % Deactivated immune system cell
    end

    % Determine how much space you want to occupy for active immune cells
    % Calculate how many active immune cells will be placed in that space
    numActiveImmuneCells = floor(immunologicalProportion * (1 / 6) / immunologicalSize^2);

    % Place active immune cells in random positions with enough space
    for k = 1:numActiveImmuneCells
        % Get a random position
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        % Check if the position is near the tumour
        [tumourRows, tumourColumns] = find(cellMatrix == 1); % Get tumour positions
        nearTumour = false;
        for t = 1:length(tumourRows)
            distance = sqrt((i - tumourRows(t))^2 + (j - tumourColumns(t))^2); % Calculate distance between random position and tumour
            if distance <= radius
                nearTumour = true;
                break; 
            end    
        end

        % If the position is near the tumour, try another random position
        if nearTumour
            continue;
        end

        % If the position is not near the tumour, place the active immune cell
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 2; % Active immune system cell
    end
end
