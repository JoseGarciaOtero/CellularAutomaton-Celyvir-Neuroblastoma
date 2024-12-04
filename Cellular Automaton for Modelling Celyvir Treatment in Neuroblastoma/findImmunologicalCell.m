function [found, index] = findImmunologicalCell(immunologicalCells, row, column)
    % Function to check if an immunological cell already exists in the list
    found = false;
    index = 0;

    for i = 1:length(immunologicalCells)
        if immunologicalCells(i).row == row && immunologicalCells(i).column == column
            found = true;
            index = i;
            break;
        end
    end
end
