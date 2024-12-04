%% In this variation, the tumour is located at one of the four corners of the grid

function [cellMatrix, mesenchymalCellCount] = initialiseEnvironment2(rows, columns, tumourSize, mesenchymalSize, immunologicalSize)
    % Initialise the grid with empty cells
    cellMatrix = zeros(rows, columns);

    % Place a seed cell at one of the four corners randomly
    corner = randi(4);
    switch corner
        case 1 % Top-left corner
            initialRow = 1;
            initialColumn = 1;
        case 2 % Top-right corner
            initialRow = 1;
            initialColumn = columns;
        case 3 % Bottom-left corner
            initialRow = rows;
            initialColumn = 1;
        case 4 % Bottom-right corner
            initialRow = rows;
            initialColumn = columns;
    end
    cellMatrix(initialRow, initialColumn) = 1;

    % Initialise variables for tumour growth
    totalSpace = rows * columns;
    tumourProportion = 0.0737; % We want the tumour to occupy [0.0737-0.2288] of the total space

    % Calculate how much space the tumour should occupy
    tumourSpace = round(totalSpace * tumourProportion);

    % Initialise variable to track the space occupied by the tumour
    occupiedTumourSpace = 1; % Initialised with the seed cell

    % Grow the tumour until it occupies the desired space
    while occupiedTumourSpace < tumourSpace
        % Calculate cell division and update the matrix
        tumourCells = cellMatrix == 1;
        tumourDivision = calculateCellDivision(cellMatrix, tumourCells, tumourSize);
        cellMatrix(tumourDivision) = 1;
        % Update the space occupied by the tumour
        occupiedTumourSpace = sum(cellMatrix(:) == 1);
        % Draw environment (optional)
        % drawEnvironment(cellMatrix, 0)
        % pause;
    end

    % Calculate the total available space, subtracting the tumour cell space
    totalSpace = sum(cellMatrix(:) == 0);

    % Determine how much space you want to occupy with mesenchymal cells
    mesenchymalProportion = round(totalSpace * 0.2829 * 0.4); 
    % Calculate how many mesenchymal cells will be placed in that space
    mesenchymalCellCount = floor(mesenchymalProportion / mesenchymalSize^2);

    %% The goal is to occupy 1/6 of the available space once the tumour is placed, with immune cells, of which 5/6 are deactivated and 1/6 remain active.
    %% Of the deactivated immune cells, 3/6 will be placed around the tumour and the rest randomly.
    % Determine how much space you want to occupy with deactivated immune cells
    immunologicalProportion = round(tumourSpace / 2); % This needs adjustment
    % Calculate how many deactivated immune cells will be placed in that space
    deactivatedImmuneCellCount = floor(immunologicalProportion * (5 / 6) / immunologicalSize^2);

    % Calculate how many deactivated immune cells will be placed around the tumour
    deactivatedImmuneCellCount_aroundTumour = floor(deactivatedImmuneCellCount * (3 / 5));

    % Calculate how many deactivated immune cells will be placed randomly
    deactivatedImmuneCellCount_random = deactivatedImmuneCellCount - deactivatedImmuneCellCount_aroundTumour;

    % Create an auxiliary logical matrix for valid positions of deactivated immune cells
    validPositionsMatrix = false(rows, columns);
    fixedRadius = 3;
    
    for i = 1:rows
        tumourColumnsInRow = find(cellMatrix(i, :) == 1);
        if ~isempty(tumourColumnsInRow)
            minColumn = min(tumourColumnsInRow);
            maxColumn = max(tumourColumnsInRow);
            
            % Minimum and maximum radius for the left and right parts of this row
            leftMinRadius = minColumn - 1;
            leftMaxRadius = minColumn - 1 - fixedRadius;
            
            bottomMinRadius = maxColumn + 1;
            bottomMaxRadius = maxColumn + 1 + fixedRadius;
    
            % Ensure indices are within the matrix bounds
            leftMinRadius = max(leftMinRadius, 1);
            leftMaxRadius = max(leftMaxRadius, 1);
            
            bottomMinRadius = min(bottomMinRadius, columns);
            bottomMaxRadius = min(bottomMaxRadius, columns);
    
            % Mark valid positions in the logical matrix
            if (corner ~= 1 && corner ~= 3) % Do not mark the left part if the tumour is in the left corner
                validPositionsMatrix(i, leftMaxRadius:leftMinRadius) = true;
            end
            if (corner ~= 2 && corner ~= 4) % Do not mark the right part if the tumour is in the right corner
                validPositionsMatrix(i, bottomMinRadius:bottomMaxRadius) = true;
            end
        end
    end

    for j = 1:columns
        tumourRowsInColumn = find(cellMatrix(:, j) == 1);
        if ~isempty(tumourRowsInColumn)
            minRow = min(tumourRowsInColumn);
            maxRow = max(tumourRowsInColumn);
            
            % Minimum and maximum radius for the upper and lower parts of this column
            upperMinRadius = minRow - 1;
            upperMaxRadius = minRow - 1 - fixedRadius;
            
            lowerMinRadius = maxRow + 1;
            lowerMaxRadius = maxRow + 1 + fixedRadius;
    
            % Ensure indices are within the matrix bounds
            upperMinRadius = max(upperMinRadius, 1);
            upperMaxRadius = max(upperMaxRadius, 1);
            
            lowerMinRadius = min(lowerMinRadius, rows);
            lowerMaxRadius = min(lowerMaxRadius, rows);
    
            % Mark valid positions in the logical matrix
            if (corner ~= 1 && corner ~= 2) % Do not mark the upper part if the tumour is in the top corner
                validPositionsMatrix(upperMaxRadius:upperMinRadius, j) = true;
            end
            if (corner ~= 3 && corner ~= 4) % Do not mark the lower part if the tumour is in the bottom corner
                validPositionsMatrix(lowerMinRadius:lowerMaxRadius, j) = true;
            end
        end
    end
    
    % Place deactivated immune cells around the tumour
    validPositionsIndices = find(validPositionsMatrix);
    numValidPositions = numel(validPositionsIndices);
    
    while deactivatedImmuneCellCount_aroundTumour > 0 && numValidPositions > 0
        idx = randi(numValidPositions);
        pos = validPositionsIndices(idx);
        cellMatrix(pos) = 4; % Deactivated immune cells
        deactivatedImmuneCellCount_aroundTumour = deactivatedImmuneCellCount_aroundTumour - 1;
        % Remove the selected position from the valid positions list
        validPositionsIndices(idx) = [];
        numValidPositions = numValidPositions - 1;
    end

    % Place mesenchymal cells in random positions with sufficient space
    for k = 1:mesenchymalCellCount
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        if cellMatrix(i, j) == 0
            cellMatrix(i, j) = 0; % Mesenchymal cell
        end
    end

    % Place random deactivated immune cells
    for k = 1:deactivatedImmuneCellCount_random
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 4; % Deactivated immune cell
    end

    % Determine how much space you want to occupy with active immune cells
    % Calculate how many active immune cells will be placed in that space
    activeImmuneCellCount = floor(immunologicalProportion * (1 / 6) / immunologicalSize^2);

    % Place active immune cells in random positions with sufficient space
    for k = 1:activeImmuneCellCount
        % Get a random position
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        % Check if the position is near the tumour
        [tumourRows, tumourColumns] = find(cellMatrix == 1); % Get tumour positions
        nearTumour = false;
        for t = 1:length(tumourRows)
            distance = sqrt((i - tumourRows(t))^2 + (j - tumourColumns(t))^2); % Calculate distance from random position to tumour
            if distance <= radius
                nearTumour = true;
                break; 
            end    
        end

        % If the position is near the tumour, find another random position
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
