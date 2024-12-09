% This MATLAB script, calculataErrorAutomaton, is designed to calculate 
% the error and the standard deviation associated with the tumor population
% in a probabilistic cellular automaton model. The function runs
% "num_simulations" simulations using the same configuration defined in the
% main file simulateCellularAutomaton.m. Since the cellular automaton is 
% probabilistic, each simulation produces slightly different outcomes. 
% The script computes the error and the standard deviation of the tumor 
% population across all simulations, providing insight into the variability
% and uncertainty of the model.


function [times_with_data, mean_results, std_results] = calculateErrorAutomaton()
    profile on;

    % Number of simulations to perform
    num_simulations = 100;

    % Perform simulations and store the results
    simulation_results = cell(1, num_simulations);
    parfor i = 1:num_simulations
        % Run the simulation and save the results
        [~, ~, time_data] = simulateCellularAutomaton();
        simulation_results{i} = time_data;
        disp(['Repetition number ', num2str(i)]);
    end

    % Calculate the mean and standard error of the results at each time step
    num_times = length(simulation_results{1}); % Get the number of times
    mean_results = nan(1, num_times); % Initialise with NaN to represent missing values
    std_results = nan(1, num_times); % Initialise with NaN to represent missing values

    for k = 1:num_times
        % Get the data for the results at time k for all simulations
        time_results = nan(1, num_simulations); % Initialise with NaN to represent missing values
        for j = 1:num_simulations
            if isfield(simulation_results{j}(k), 'totalTumourCells') && ~isempty(simulation_results{j}(k).totalTumourCells)
                time_results(j) = simulation_results{j}(k).totalTumourCells;
            end
        end

        % Exclude NaN values (originally missing values)
        valid_results = time_results(~isnan(time_results));

        % Calculate the mean and standard error of the results at time k
        if ~isempty(valid_results)
            mean_results(k) = mean(valid_results);
            std_results(k) = std(valid_results) / sqrt(length(valid_results));
        end
    end

    % Get the times of the simulation with available data
    times_with_data = find(~isnan(mean_results));

    % Plot the mean and standard error
    figure;
    hold on;

    % Create the shaded area for the standard error using patch
    x_patch = [times_with_data, fliplr(times_with_data)];
    y_patch = [mean_results(times_with_data) + std_results(times_with_data), ...
               fliplr(mean_results(times_with_data) - std_results(times_with_data))];

    patch('XData', x_patch, 'YData', y_patch, 'FaceColor', 'blue', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

    % Plot the mean line in strong red and dashed
    plot(times_with_data, mean_results(times_with_data), 'r--', 'LineWidth', 2);

    xlabel('Time (months)');
    ylabel('Cancer Cells');
    title('Mean of Results with Standard Error');
    legend('Standard Error', 'Mean');
    xticks(linspace(1, 168*4*12, 13)); % Divide the x-axis into 12 intervals (each month)
    xticklabels(0:12);
    grid on;
    hold off;
    xlim([0 inf]);
    ylim([0 inf]);

    % Adjust the font size of the figure
    set(gca, 'FontSize', 20);
    titleHandle = get(gca, 'title');
    set(titleHandle, 'FontSize', 20);
    xlabelHandle = get(gca, 'xlabel');
    ylabelHandle = get(gca, 'ylabel');
    set(xlabelHandle, 'FontSize', 20);
    set(ylabelHandle, 'FontSize', 20);
    legendHandle = findobj(gcf, 'Type', 'Legend');
    set(legendHandle, 'FontSize', 20);

    profile off;
    profile viewer;
end


