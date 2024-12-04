% In this variation, the tumour is located at one of the four
function [cellMatrix, numMesenchymalCells] = initialiseEnvironment3(rows, columns, tumourSize, mesenchymalSize, immunologicalSize)
    % Initialises the grid with empty cells
    cellMatrix = zeros(rows, columns);

    % Defines the initial position of the tumour in the middle of the grid
    midRows = ceil(rows / 2);
    midColumns = ceil(columns / 2);

    % Randomly decides whether to place the tumour in the top or bottom if it's in the central rows
    % or in the left or right if it's in the central columns
    if rand < 0.5 % Place the tumour in the top or bottom
        if rand < 0.5 % Place the tumour at the top
            tumourRow = 1;
        else % Place the tumour at the bottom
            tumourRow = rows;
        end
        tumourColumn = midColumns; % Place the tumour in the central column
    else % Place the tumour in the left or right
        if rand < 0.5 % Place the tumour at the left
            tumourColumn = 1;
        else % Place the tumour at the right
            tumourColumn = columns;
        end
        tumourRow = midRows; % Place the tumour in the central row
    end

    cellMatrix(tumourRow, tumourColumn) = 1;

    % Initialises variables for tumour growth
    totalSpace = rows * columns;
    tumourProportion = 0.0737; % We want the tumour to occupy [0.0737-0.2288] of the total space

    % Calculates how much space the tumour will occupy
    tumourSpace = round(totalSpace * tumourProportion);

    % Initialises the variable to store the space occupied by the tumour
    occupiedTumourSpace = 1; % Initialised with the seed cell

    % Grows the tumour until it occupies the desired space
    while occupiedTumourSpace < tumourSpace
        % Calculates cell division and updates the matrix
        tumourCells = cellMatrix == 1;
        tumourDivision = calculateCellDivision(cellMatrix, tumourCells, tumourSize);
        cellMatrix(tumourDivision) = 1;
        % Updates the occupied tumour space
        occupiedTumourSpace = sum(cellMatrix(:) == 1);
        %drawEnvironment(cellMatrix, 0)
        %pause;
    end

    % Calculates the total available space, excluding the space occupied by tumour cells
    totalSpace = sum(cellMatrix(:) == 0);

    % Determines how much space should be occupied by mesenchymal cells
    mesenchymalProportion = round(totalSpace * 0.2829 * 0.4); 
    % Calculates how many mesenchymal cells will be placed in that space
    numMesenchymalCells = floor(mesenchymalProportion / mesenchymalSize^2);

    %% The idea is to occupy 1/6 of the available space once the tumour is placed with immune cells, of which 5/6 are deactivated and 1/6 remain active.
    %% Of the deactivated immune cells, 3/6 will be placed around the tumour and the rest randomly 
    % Determines how much space should be occupied by deactivated immune cells
    immunologicalProportion = round(tumourSpace / 2); % This needs to be adjusted
    % Calculates how many deactivated immune cells will be placed in that space
    numDeactivatedImmuneCells = floor(immunologicalProportion * (5 / 6) / immunologicalSize^2);

    % Calculates how many deactivated immune cells will be placed around the tumour
    numDeactivatedImmuneCells_tumour = floor(numDeactivatedImmuneCells * (3 / 5));

    % Calculates how many deactivated immune cells will be placed randomly
    numDeactivatedImmuneCells_random = numDeactivatedImmuneCells - numDeactivatedImmuneCells_tumour;

    % Creates an auxiliary logical matrix for valid positions of deactivated immune cells
    validPositionsMatrix = false(rows, columns);
    fixedRadius = 3;
    
    for i = 1:rows
        tumourColumnsRow = find(cellMatrix(i, :) == 1);
        if ~isempty(tumourColumnsRow)
            minColumn = min(tumourColumnsRow);
            maxColumn = max(tumourColumnsRow);
            
            % Minimum and maximum range for the left and right parts of this row
            minLeftRange = minColumn - 1;
            maxLeftRange = minColumn - 1 - fixedRadius;
            
            minBottomRange = maxColumn + 1;
            maxBottomRange = maxColumn + 1 + fixedRadius;
    
            % Ensures the indices are within the matrix bounds
            minLeftRange = max(minLeftRange, 1);
            maxLeftRange = max(maxLeftRange, 1);
            
            minBottomRange = min(minBottomRange, columns);
            maxBottomRange = min(maxBottomRange, columns);
    
            % Marks valid positions in the logical matrix
            if tumourColumn ~= 1 || minColumn ~= 1 % Do not mark the left part if the tumour is in the left column
                validPositionsMatrix(i, maxLeftRange:minLeftRange) = true;
            end
            if tumourColumn ~= columns || maxColumn ~= columns % Do not mark the right part if the tumour is in the right column
                validPositionsMatrix(i, minBottomRange:maxBottomRange) = true;
            end
        end
    end
    
    for j = 1:columns
        tumourRowsColumn = find(cellMatrix(:, j) == 1);
        if ~isempty(tumourRowsColumn)
            minRow = min(tumourRowsColumn);
            maxRow = max(tumourRowsColumn);
            
            % Minimum and maximum range for the top and bottom parts of this column
            minTopRange = minRow - 1;
            maxTopRange = minRow - 1 - fixedRadius;
            
            minBottomRange = maxRow + 1;
            maxBottomRange = maxRow + 1 + fixedRadius;
    
            % Ensures the indices are within the matrix bounds
            minTopRange = max(minTopRange, 1);
            maxTopRange = max(maxTopRange, 1);
            
            minBottomRange = min(minBottomRange, rows);
            maxBottomRange = min(maxBottomRange, rows);
    
            % Marks valid positions in the logical matrix
            if tumourRow ~= 1 || minRow ~= 1 % Do not mark the top part if the tumour is in the top row
                validPositionsMatrix(maxTopRange:minTopRange, j) = true;
            end
            if tumourRow ~= rows || maxRow ~= rows % Do not mark the bottom part if the tumour is in the bottom row
                validPositionsMatrix(minBottomRange:maxBottomRange, j) = true;
            end
        end
    end
     

    % Places deactivated immune cells randomly in valid positions
    validPositionsIndices = find(validPositionsMatrix);
    numValidPositions = numel(validPositionsIndices);
    
    while numDeactivatedImmuneCells_tumour > 0 && numValidPositions > 0
        idx = randi(numValidPositions);
        pos = validPositionsIndices(idx);
        cellMatrix(pos) = 4; % Deactivated immune system cells
        numDeactivatedImmuneCells_tumour = numDeactivatedImmuneCells_tumour - 1;
        % Removes the selected position from the list of valid positions
        validPositionsIndices(idx) = [];
        numValidPositions = numValidPositions - 1;
    end

    % Places mesenchymal cells in random positions with enough space
    for k = 1:numMesenchymalCells
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        if cellMatrix(i, j) == 0
            cellMatrix(i, j) = 0; % Mesenchymal cell
        end
    end

    % Places random deactivated immune cells
    for k = 1:numDeactivatedImmuneCells_random
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        startRow = max(i - radius, 1);
        endRow = min(i + radius, rows);
        startColumn = max(j - radius, 1);
        endColumn = min(j + radius, columns);
        cellMatrix(startRow:endRow, startColumn:endColumn) = 4; % Deactivated immune system cell
    end

    % Determines how much space should be occupied by active immune cells
    % Calculates how many active immune cells will be placed in that space
    numActiveImmuneCells = floor(immunologicalProportion * (1 / 6) / immunologicalSize^2);

    % Places active immune cells in random positions with enough space
    for k = 1:numActiveImmuneCells
        % Gets a random position
        [i, j] = getRandomPositionWithSpace(cellMatrix);
        radius = floor(immunologicalSize / 2);
        % Checks if the position is near the tumour
        [tumourRows, tumourColumns] = find(cellMatrix == 1); % Gets the positions of the tumour
        nearTumour = false;
        for t = 1:length(tumourRows)
            distance = sqrt((i - tumourRows(t))^2 + (j - tumourColumns(t))^2); % Distance to the tumour
            if distance <= radius
                % Active immune cells should be placed near the tumour
                nearTumour = true;
                break;
            end
        end
        if nearTumour
            cellMatrix(i, j) = 3; % Active immune cell
        else
            cellMatrix(i, j) = 0; % Mesenchymal cell
        end
    end
end

