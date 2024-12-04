# Cellular Automaton for Modelling Celyvir Treatment in Neuroblastoma

This repository contains the code for the cellular automaton developed in **Matlab** to simulate the interactions between cancer cells, immune cells, and the oncolytic virus ICOVIR-5 encapsulated in mesenchymal stem cells (MSC) in the context of neuroblastoma treatment with Celyvir. This code accompanies the forthcoming research article:

**Exploring Neuroblastoma’s Cellular Microenvironment: A Novel Approach Using Cellular Automata to Model Celyvir Treatment**  
*Authors: José Garcia Otero, Juan Belmonte-Beitia, Juan Jiménez Sánchez*  
*Expected to be published in Computers in Biology and Medicine*.

## About the Cellular Automaton

The cellular automaton was designed to:  
- Simulate the tumour microenvironment in neuroblastoma.  
- Model the effects of Celyvir treatment, including the interactions between the oncolytic virus ICOVIR-5 encapsulated in MSC and tumour cells.  
- Incorporate the behaviour of immune cells, including T-cell exhaustion and effector dynamics.  

The code allows researchers to perform simulations under various treatment conditions and parameter configurations to study the dynamics of the tumour-immune-virus system.

## How to Use the Code

1. Clone or download this repository to your local machine.
2. Open the `simulateCellularAutomaton.m` file in Matlab to explore the main simulation script.
3. Adjust the initial conditions of the cellular automaton by modifying the `initialiseEnvironment.m` file.  
   - Four types of initial conditions are available for configuring the tumour's placement:  
     1. `initialiseEnvironment`: Places the tumour in the centre of the grid.  
     2. `initialiseEnvironment1`: Configures two cohesive tumour lesions in the centre of the grid.  
     3. `initialiseEnvironment2`: Positions the tumour in one of the four corners of the grid.  
     4. `initialiseEnvironment3`: Places the tumour along one of the grid's edges (top, bottom, left, or right) but not in the corners, ensuring that only one side of the tumour is adjacent to the boundary.

4. The treatment protocols can be modified in the `updateCells.m` file. This file orchestrates the execution of various rules at each time step and controls the treatment schedule (e.g., the treatment can be administered once a week, with rest weeks in between, etc.). The treatment regimen can be adjusted by modifying this file.

5. The following files are called by `updateCells.m` to execute the individual automaton rules:
   - `shouldToumourDie.m`: Determines whether the tumour cells should die based on specific conditions.
   - `shouldMesenchymalDie.m`: Decides whether the mesenchymal cells should die.
   - `shouldDeactivatedImmunological.m`: Determines whether deactivated immune cells should be reactivated or die.
   - `shouldDeactivatedImmuneDie.m`: Determines if the deactivated immune cells should die based on the environment.
   - `reactivateDeactivatedImmuneCells.m`: Reactivates the deactivated immune cells under certain conditions.
   - `moveImmuneCells.m`: Moves the immune cells through the environment.
   - `calculateCellDivision.m`: Determines how cells should divide based on the current conditions.

6. The `calculate_error_automaton.m` file calculates the error associated with the cellular automaton, but only for the tumour cell population. This error is computed relative to the configuration of tumour cells in the main simulation (`simulateCellularAutomaton.m`).

The code is well-commented and designed to follow step-by-step instructions. The main files have a brief description at the beginning to help understand their purpose and guide you through the process.

## Citation

If you use this code in your research, **please reference the original article**:  
> José Garcia Otero, Juan Belmonte-Beitia, Juan Jiménez Sánchez.  
> *Exploring Neuroblastoma’s Cellular Microenvironment: A Novel Approach Using Cellular Automata to Model Celyvir Treatment*.  
> *Expected to be published in Computers in Biology and Medicine*.

Your acknowledgment of this work helps us ensure proper credit for the efforts involved in developing the model. Thank you for your cooperation!
