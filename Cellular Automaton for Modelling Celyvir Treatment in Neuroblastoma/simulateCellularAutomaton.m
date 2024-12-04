% Main programme for cellular automaton simulation

function [cellMatrix, tumouralDeath, timeData] = simulateCellularAutomaton()

    % Start profiling to calculate the computational cost of the simulation
    profile on

    % Simulation parameters
    rows = 200;
    columns = 200;
    interval = 12; % Simulation will run every 12 hours
    simulationDuration = (168*4)*12*1; % One week in hours (7 days * 24 hours/day)

    tumourSize = 1;
    mesenchymalSize = 1;
    immuneSize = 1;

    % Initialise the environment
% Four types of initial conditions are available for configuring the tumour's placement:
% 1. initialiseEnvironment: Places the tumour in the centre of the grid.
% 2. initialiseEnvironment1: Configures two cohesive tumour lesions in the centre of the grid.
% 3. initialiseEnvironment2: Positions the tumour in one of the four corners of the grid.
% 4. initialiseEnvironment3: Places the tumour along one of the grid's edges (top, bottom, left, or right) 
%    but not in the corners, ensuring that only one side of the tumour is adjacent to the boundary.

    [cellMatrix, numMesenchymalCells] = initialiseEnvironment(rows, columns, tumourSize, mesenchymalSize, immuneSize);

    % Specify the folder where the images will be saved
%     outputFolder = '/Users/';


    figure;
    drawEnvironment(cellMatrix, 0);
%     saveFiguresToEPS(outputFolder, 0);
%     close(gcf); % Close the current figure

    % Structure to store data at each time step
    timeData = struct('time', {}, 'totalTumourCells', [], 'totalImmuneCells', [], 'totalMesenchymalCells', [], 'tumourCellDeath', []);
    t = 0;

    % Simulation loop
    for time = interval:interval:simulationDuration

        % Perform cellular updates
        [updatedCellMatrix, tumouralDeath, t] = updateCells(cellMatrix, tumourSize, mesenchymalSize, immuneSize, numMesenchymalCells, time, t);
        cellMatrix = updatedCellMatrix;

        % Calculate the total count of each cell type and normalise by their respective sizes
        totalTumourCells = sum(cellMatrix(:) == 1) / tumourSize^2;
        totalImmuneCells = sum(cellMatrix(:) == 3) / immuneSize^2;
        totalMesenchymalCells = sum(cellMatrix(:) == 2) / mesenchymalSize^2;
        totalInactiveImmuneCells = sum(cellMatrix(:) == 4) / immuneSize^2;

        % Store the data in the structure
        timeData(time).time = time;
        timeData(time).totalTumourCells = totalTumourCells;
        timeData(time).totalImmuneCells = totalImmuneCells;
        timeData(time).totalMesenchymalCells = totalMesenchymalCells;
        timeData(time).totalInactiveImmuneCells = totalInactiveImmuneCells;

        % Draw the current state of the environment
        if mod(time, 672) == 0
            figure;
            drawEnvironment(cellMatrix, time);
%             saveFiguresToEPS(outputFolder, time);
%             close(gcf);
        end
        
        % Display the time progress
        disp(['Time: ', num2str(time)]);
    end  

    % Stop profiling
    profile off;
    profile viewer;

    % Plot the evolution of the total cell count and tumoural death over time
    figure;
    hold on;

    % Graphs with increased line thickness
    plot([timeData.time], [timeData.totalTumourCells], 'Color', [49/255 0 73/255], 'LineWidth', 5);
    plot([timeData.time], [timeData.totalImmuneCells], 'Color', [0 1 1], 'LineWidth', 5);
    plot([timeData.time], [timeData.totalInactiveImmuneCells], 'Color', [0 0 1], 'LineWidth', 5);

    % Graph for mesenchymal cells with transparency
    h = plot([timeData.time], [timeData.totalMesenchymalCells], 'Color', [255/255 0/255 255/255], 'LineWidth', 5);
    set(h, 'Color', [255/255 0/255 255/255 0.4]); % Set colour with transparency (alpha = 0.4)

    xlabel('Time (Months)');
    ylabel('Cells');
    title('Evolution of total cell count');
    legend('Tumour Cells', 'Immune Cells', 'Inactive Immune Cells', 'Mesenchymal Cells');
    xticks(linspace(1, 168*4*12, 13)); % Divide the x-axis into 13 intervals (one per month)
    xticklabels(0:12);
    xlim([0 inf]);
    ylim([0 inf]);
    grid on;

    % Adjust font sizes in the figure
    fig = gcf;

    % Modify the title font size
    titleFontSize = 20; % Font size for the title
    titleHandle = get(gca, 'title');
    set(titleHandle, 'FontSize', titleFontSize);

    % Modify axis label font size
    labelFontSize = 20; % Font size for axis labels
    xlabelHandle = get(gca, 'xlabel');
    ylabelHandle = get(gca, 'ylabel');
    set(gca, 'FontSize', labelFontSize);
    set(xlabelHandle, 'FontSize', labelFontSize);
    set(ylabelHandle, 'FontSize', labelFontSize);

    % Modify legend font size
    legendFontSize = 20; % Font size for the legend
    legendHandle = findobj(fig, 'Type', 'Legend');
    set(legendHandle, 'FontSize', legendFontSize);

end
