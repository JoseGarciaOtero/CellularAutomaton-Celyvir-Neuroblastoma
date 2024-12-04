function neighbours = calculateNeighbours(cellMatrix, row, column, neighbourhoodSize)
    % Grid size
    [numRows, numColumns] = size(cellMatrix);
          
    if row == numRows || column == numColumns || row == 1 || column == 1 % if this cell is at the edge
        neighbours = calculateEdgeNeighbours(cellMatrix, row, column, neighbourhoodSize);    
        return
    else % if it is not at the edge
        startRow = row - neighbourhoodSize;
        startColumn = column - neighbourhoodSize;
        endRow = row + neighbourhoodSize;
        endColumn = column + neighbourhoodSize;

        startRow = max(startRow, 1);
        startColumn = max(startColumn, 1);
        endRow = min(endRow, numRows);
        endColumn = min(endColumn, numColumns);

        % Extract the neighbourhood submatrix
        subMatrix = cellMatrix(startRow:endRow, startColumn:endColumn);
        subMatrix1 = [subMatrix(1:neighbourhoodSize, :); subMatrix(end-neighbourhoodSize+1:end, :)];
        subMatrix2 = [subMatrix(neighbourhoodSize+1:end-neighbourhoodSize, 1:neighbourhoodSize); subMatrix(neighbourhoodSize+1:end-neighbourhoodSize, end-neighbourhoodSize+1:end)];
        subMatrix = [subMatrix1(:); subMatrix2(:)];
        neighbours = subMatrix';
        return
    end

end
