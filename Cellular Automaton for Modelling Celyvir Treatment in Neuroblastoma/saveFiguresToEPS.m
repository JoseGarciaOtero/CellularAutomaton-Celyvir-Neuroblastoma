function saveFiguresToEPS(destination_folder, time)
    % Make sure the destination folder exists
    if ~exist(destination_folder, 'dir')
        mkdir(destination_folder);
    end

    % Set the maximum figure size
    % Get the screen dimensions in pixels
    screen_size = get(0, 'ScreenSize');

    % Set the desired maximum width
    max_width = 2560 / 2;

    % Calculate the height proportionally
    max_height = screen_size(4) * (max_width / screen_size(3));
    max_size = [max_width, max_height]; % Specify the maximum size in pixels
    
    % Set the maximum size       
    set(gcf, 'Position', [0, 0, max_size]);  
    % Generate the EPS file name for this figure     
    eps_file_name = fullfile(destination_folder, ['figure_' num2str(time) '.eps']);
    % Save the figure as an EPS file
    print(gcf, eps_file_name, '-depsc', '-r300');

    disp('It has been saved successfully!');
end
