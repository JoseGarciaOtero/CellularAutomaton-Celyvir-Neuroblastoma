function tumourDivision = calculateCellDivision(cellMatrix, tumourCells, tumourSize)
    [rows, columns] = size(cellMatrix);
    tumourDivision = false(rows, columns);  % Initialise the division matrix

    % Loop through the tumour cell matrix
    for i = 1:rows
        for j = 1:columns
            if tumourCells(i, j)          
                % Determine if the cell divides with an 80% probability
                if rand() <= 0.8              
                    % Calculate the positions where it can divide
                    divisionPositions = spaceToDivide(cellMatrix, i, j, tumourSize);  
                    % If there is space to divide                   
                    if ~isempty(divisionPositions)                            
                        % In this loop, we choose the index so that we don't overlap with daughter tumour cells from
                        % another cell that has already divided                         
                        while ~isempty(divisionPositions)                       
                            index = randi(size(divisionPositions, 1));
                            divisionRow = divisionPositions(index, 1); % this is the row of the central cell   
                            divisionColumn = divisionPositions(index, 2); % this is the column of the central cell   
                            
                            if isequal(tumourDivision(divisionRow, divisionColumn),zeros(tumourSize))...
                                        && isequal(cellMatrix(divisionRow , divisionColumn),zeros(tumourSize))                    
                                % Mark the positions occupied by the new daughter cell                                     
                                tumourDivision(divisionRow, divisionColumn) = true;                            
                                break;                       
                            else                                 
                                divisionPositions(index,:)=[];  
                            end 
                        end                                                
                            
                        % Update the tumour cell matrix                           
                        % to know that those positions have already been checked for division possibility 
                        tumourCells(i,j) = false;                      
                    end                    
                end               
            end      
        end
            
        % Now, we will check if there is an empty cell of size 3x3     
        % surrounded by 3 or more tumour cells; this gap will be filled with a          
        % 90% probability            
        if isequal(cellMatrix(i,j),zeros(tumourSize))              
            neighbours = calculateNeighbours(cellMatrix,i,j,1);        
            if sum(neighbours(:)==1)>=3 && rand() <= 0.9
                tumourDivision(i,j) = true;
            end  
        end
        
    end
end


