function [cellMatrix, mesenchymalCellCount] = initialiseEnvironment(rows, columns, tumourSize, mesenchymalSize, immuneSize)
    % Initialise the grid with empty cells
    cellMatrix = zeros(rows, columns);

    % Place a seed cell at the centre
    centreRow = ceil(rows / 2);
    centreColumn = ceil(columns / 2);
    cellMatrix(centreRow, centreColumn) = 1;

    % Initialise variables for tumour growth
    totalSpace = rows * columns;
    tumourRatio = 0.0737; % We want the tumour to occupy [0.0737-0.2288] of the total space

    % Calculate how much space the tumour needs to occupy
    tumourSpace = round(totalSpace * tumourRatio);

    % Initialise variable to store the space occupied by the tumour
    occupiedTumourSpace = 1; % Initially with the seed cell

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

    % Calculate the total available space, subtracting the space occupied by tumour cells
    totalSpace = sum(cellMatrix(:) == 0);

    % Determine how much space you want to occupy (of the total space) for mesenchymal cells
    mesenchymalRatio = round(totalSpace * 0.2829 * 0.4);
    % Calculate how many mesenchymal cells will be placed in that space
    mesenchymalCellCount = floor(mesenchymalRatio / mesenchymalSize^2);


    %% The idea is to occupy 1/6 of the available space once the tumour is placed with immune cells, of which 5/6 have been deactivated and 1/6 remain active.
    %% Of the deactivated I, 3/6 will be placed around the tumour and the rest randomly
    % Determine how much space you want to occupy for deactivated immune cells
    immuneRatio = round(tumourSpace / 2);
    % Calculate how many deactivated immune cells will be placed in that space
    deactivatedImmuneCellCount = floor(immuneRatio * (5 / 6) / immuneSize^2);

    % Calculate how many deactivated immune cells will be placed around the tumour
    deactivatedImmuneCellsAroundTumour = floor(deactivatedImmuneCellCount * (3 / 5));

    % Calculate how many deactivated immune cells will be placed randomly
    deactivatedImmuneCellsRandom = deactivatedImmuneCellCount - deactivatedImmuneCellsAroundTumour;

    % Create auxiliary logical matrix for valid positions of deactivated immune cells
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
            
            minRadiusRight = maxColumn + 1;
            maxRadiusRight = maxColumn + 1 + fixedRadius;
    
            % Ensure indices are within matrix bounds
            minRadiusLeft = max(minRadiusLeft, 1);
            maxRadiusLeft = max(maxRadiusLeft, 1);
            
            minRadiusRight = min(minRadiusRight, columns);
            maxRadiusRight = min(maxRadiusRight, columns);
    
            % Mark valid positions in the logical matrix
            validPositionsMatrix(i, maxRadiusLeft:minRadiusLeft) = true;
            validPositionsMatrix(i, minRadiusRight:maxRadiusRight) = true;
        end
    end

    for j = 1:columns
        tumourRowsInColumn = find(cellMatrix(:, j) == 1);
        if ~isempty(tumourRowsInColumn)
            minRow = min(tumourRowsInColumn);
            maxRow = max(tumourRowsInColumn);
            
            % Minimum and maximum radius for the left and right parts of this row
            minRadiusUp = minRow - 1;
            maxRadiusUp = minRow - 1 - fixedRadius;
            
            minRadiusDown = maxRow + 1;
            maxRadiusDown = maxRow + 1 + fixedRadius;
    
            % Ensure indices are within matrix bounds
            minRadiusUp = max(minRadiusUp, 1);
            maxRadiusUp = max(maxRadiusUp, 1);
            
            minRadiusDown = min(minRadiusDown, columns);
            maxRadiusDown = min(maxRadiusDown, columns);
    
            % Mark valid positions in the logical matrix
            validPositionsMatrix(maxRadiusUp:minRadiusUp, j) = true;
            validPositionsMatrix(minRadiusDown:maxRadiusDown, j) = true;
        end
    end
    
    % Place deactivated immune cells randomly in valid positions
    validPositionIndices = find(validPositionsMatrix);
    numValidPositions = numel(validPositionIndices);
    
    while deactivatedImmuneCellsAroundTumour > 0 && numValidPositions > 0
        idx = randi(numValidPositions);
        pos = validPositionIndices(idx);
        cellMatrix(pos) = 4; % Deactivated immune cells
        deactivatedImmuneCellsAroundTumour = deactivatedImmuneCellsAroundTumour - 1;
        % Remove the selected position from the valid positions list
        validPositionIndices(idx) = [];
        numValidPositions = numValidPositions - 1;
    end



    % Place mesenchymal cells in random positions with enough space
    for k = 1:mesenchymalCellCount
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        if cellMatrix(i, j) == 0
            cellMatrix(i, j) = 0; % Mesenchymal cell
        end
    end

    % Place random deactivated immune cells
    for k = 1:deactivatedImmuneCellsRandom
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immuneSize / 2);
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 4; % Deactivated immune cell
    end

    % Determine how much space you want to occupy for active immune cells
    % Calculate how many active immune cells will be placed in that space
    activeImmuneCellCount = floor(immuneRatio * (1 / 6) / immuneSize^2);

    % Place active immune cells in random positions with enough space
    for k = 1:activeImmuneCellCount
        % Get a random position
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immuneSize / 2);
        % Check if the position is near the tumour
        [tumourRows, tumourColumns] = find(cellMatrix == 1); % Get the tumour positions
        nearTumour = false;
        for t = 1:length(tumourRows)
            distance = sqrt((i - tumourRows(t))^2 + (j - tumourColumns(t))^2); % Calculate the distance between the random position and the tumour
            if distance <= radius
                nearTumour = true;
                break; 
            end    
        end

        % If the position is near the tumour, search for another random position
        if nearTumour
            continue;
        end

        % If the position is not near the tumour, place the active immune cell
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 3; % Active immune cell

    end
end
