function drawEnvironment(cellMatrix, time)
    % Define a colour palette for each cell type

    colours = [ 255/255 1 255/255;        % Empty (white)
                49/255 0/255 73/255;      % Tumour (black)
                255/255 0/255 255/255;   % Mesenchymal cell (magenta)
                0 1 1;                   % Active immune system cell (light blue)
                0 0 1];                  % Inactive immune system cell (dark blue)

    % Add 1 to the cell matrix to adjust the indices for the colour palette
    visualisationMatrix = cellMatrix + 1;

    % Get the x and y coordinates of the cells
    [rows, columns] = find(visualisationMatrix > 0);

    % Point size
    pointSize = 80;

    % Display the cells as circles using scatter
    scatter(columns, rows, pointSize, colours(visualisationMatrix(visualisationMatrix > 0), :), 'filled', 'Marker', 'o');
    % axis tight;  % Removes margins by automatically adjusting axis limits
    axis equal;

    % Set a title for the figure
    title('Cellular Automaton');

    % Label the axes (adjust as needed)
    xlabel('Columns');
    ylabel('Rows');

    % Adjust the image appearance
    axis off;

    % Display the current time as the title
    title(['Time (hours): ', num2str(time)]);
    
end
