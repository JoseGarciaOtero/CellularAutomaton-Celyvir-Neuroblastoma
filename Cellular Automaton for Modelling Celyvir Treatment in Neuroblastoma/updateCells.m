% The updateCells.m program is responsible for executing the various rules 
% of the cellular automaton at each time step to update the grid. It 
% iterates over the grid, applying the defined rules to update the state 
% of each cell based on its current state and the states of its neighbors.
% This process is repeated at each time step to simulate the evolution of
% the system over time, ensuring that the cellular automaton progresses
% according to the established dynamics.

function [updatedCellMatrix, tumouralDeaths, t] = updateCells(cellMatrix, tumourSize, mesenchymalSize, immuneSize, numMesenchymalCells, time, t)
    % Initialise the updated cell matrix with the existing matrix
    updatedCellMatrix = cellMatrix;
    [rows, columns] = size(updatedCellMatrix);

    %% Update tumoural cells
    tumouralCells = cellMatrix == 1;

    % Check if a tumoural cell should die and convert its position to mesenchymal if needed
    [tumouralDeaths, conversion] = shouldTumourDie(cellMatrix, tumouralCells, tumourSize, immuneSize);
    updatedCellMatrix(tumouralDeaths) = 0; % Death of tumoural cells
    updatedCellMatrix(conversion) = 2; % Conversion to mesenchymal cells

    %% Update immune system cells

    % Apply deactivation rules for immune cells
    % Every 6-12 hours, T lymphocytes become dysfunctional. Here, it is set to 12 hours.
    deactivatedImmuneDeaths = shouldDeactivatedImmuneDie(cellMatrix);
    updatedCellMatrix(deactivatedImmuneDeaths) = 0;
    ImmuneDeaths = shouldDeactivatedImmunological(cellMatrix);
    updatedCellMatrix(ImmuneDeaths) = 4; % Deactivation of immune cells

    %% Update mesenchymal cells

    % Apply death rules for mesenchymal cells
    mesenchymalDeaths = shouldMesenchymalDie(cellMatrix, immuneSize);
    updatedCellMatrix(mesenchymalDeaths) = 0; % Death of mesenchymal cells

    % Mesenchymal cells move towards tumoural cells
    tumouralCells = updatedCellMatrix == 1;
    if any(tumouralCells(:))
        numPositions = 17;
        [deaths, newMesenchymal] = moveCells(cellMatrix, tumouralCells, mesenchymalSize, numPositions);
        updatedCellMatrix(deaths) = 0;
        updatedCellMatrix(newMesenchymal) = 2;
    end

    % If 72 hours have passed, tumoural cells divide
    if mod(time, 72) == 0
        % Calculate cell division for tumoural cells
        cellDivision = calculateCellDivision(cellMatrix, tumouralCells, tumourSize);
        updatedCellMatrix(cellDivision) = 1;
    end

    %% MSC cells die 72 hours after being administered
    if mod(time, t) == 0
        naturalMSCDeaths = updatedCellMatrix == 2;
        updatedCellMatrix(naturalMSCDeaths) = 0;
        t = 0;
    end

    %% Apply treatment to mesenchymal cells according to the defined schedule

   % Define treatment and rest cycle
    treatmentCycle = 168 * 1; % 1 week in hours (total treatment period)
    restCycle = 168 * 0; % 0 weeks in hours (no rest period in this case)
    totalCycle = treatmentCycle + restCycle;
    
    % treatmentHours specifies the hours within the treatment cycle when the treatment is applied
    treatmentHours = 168; % Treatment is given every 168 hours within the treatment cycle
    % For example, if treatmentCycle is 168 and treatmentHours is 72, treatment is given at hour 72 and hour 144 of the cycle.


    % Calculate the current hour in the cycle
    hourInCycle = mod(time, totalCycle);

    % Adjust weekInCycle calculation based on treatment duration
    if treatmentHours == 168
        if mod(treatmentCycle, 168) ~= 0 || hourInCycle == 0
            weekAdjustment = 1;
        else
            weekAdjustment = 0;
        end
    else
        weekAdjustment = 1;
    end

    % Calculate the current week in the cycle
    weekInCycle = floor(hourInCycle / treatmentCycle) + weekAdjustment;

    % Check if in the first week of the cycle (treatment)
    if weekInCycle == 1
        if treatmentHours ~= 72
            % Check if it is time to administer treatment
            if mod(hourInCycle, treatmentHours) == 0 && hourInCycle <= treatmentCycle
                t = time + 72;
                % Administer treatment by adding mesenchymal cells
                while numMesenchymalCells > 0
                    [i, j] = getRandomPositionWithSpace(updatedCellMatrix);
                    if updatedCellMatrix(i, j) == 0
                        updatedCellMatrix(i, j) = 2; % Mesenchymal cell
                        numMesenchymalCells = numMesenchymalCells - 1;
                    end
                end
            end
        else
            if mod(hourInCycle, treatmentHours) == 0 && hourInCycle <= treatmentCycle && hourInCycle ~= 0
                t = time + 72;
                while numMesenchymalCells > 0
                    [i, j] = getRandomPositionWithSpace(updatedCellMatrix);
                    if updatedCellMatrix(i, j) == 0
                        updatedCellMatrix(i, j) = 2; % Mesenchymal cell
                        numMesenchymalCells = numMesenchymalCells - 1;
                    end
                end
            end
        end
    end

    %% Tumoural cell death attracts more immune system cells in quadrants
    if any(tumouralDeaths(:))
        for i = 1:2
            for j = 1:2
                % Define the current quadrant's boundaries
                rowStart = floor((i - 1) * rows / 2) + 1;
                rowEnd = min(floor(i * rows / 2), rows);
                colStart = floor((j - 1) * columns / 2) + 1;
                colEnd = min(floor(j * columns / 2), columns);

                % Check for deaths in this quadrant
                if any(tumouralDeaths(rowStart:rowEnd, colStart:colEnd), 'all')
                    % Calculate available space in the quadrant
                    availableSpace = sum(updatedCellMatrix(rowStart:rowEnd, colStart:colEnd) == 0, 'all');

                    % Calculate how many immune cells to add (e.g., x% of the available space)
                    numImmuneCells = floor(availableSpace / (rows * 20));

                    % Add random immune cells to available positions in the quadrant
                    for k = 1:numImmuneCells
                        [randRow, randCol] = getRandomPositionWithSpace(updatedCellMatrix(rowStart:rowEnd, colStart:colEnd));
                        randRow = randRow + rowStart - 1;
                        randCol = randCol + colStart - 1;
                        updatedCellMatrix(randRow, randCol) = 3; % Immune cell
                    end
                end
            end
        end
    end

    %% Deactivated immune cells reactivate and move towards nearby tumoural cells after their death
    tumouralCells = updatedCellMatrix == 1;

    % Cytokine attraction triggers movement
    if any(tumouralDeaths(:)) && any(tumouralCells(:))
        attractionRadius = 4;
        numPositions = 432;
        updatedCellMatrix = reactivateDeactivatedImmuneCells(updatedCellMatrix, tumouralDeaths, tumourSize, attractionRadius);
        [immuneDeaths, newImmuneCells] = moveImmuneCells(updatedCellMatrix, tumouralCells, tumouralDeaths, tumourSize, immuneSize, attractionRadius, numPositions);
        updatedCellMatrix(immuneDeaths) = 0;
        updatedCellMatrix(newImmuneCells) = 3;
    end
end
