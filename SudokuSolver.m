clear;
clc;
B = [1,2,2;
    1,5,3;
    1,8,4;
    2,1,6;
    2,9,3;
    3,3,4;
    3,7,5;
    4,4,8;
    4,6,6;
    5,1,8;
    5,5,1;
    5,9,6;
    6,4,7;
    6,6,5;
    7,3,7;
    7,7,6;
    8,1,4;
    8,9,8;
    9,2,3;
    9,5,4;
    9,8,2];

%drawSudoku(B)
x = optimvar('x',9,9,9,'Type','integer','LowerBound',0,'UpperBound',1);

%Create an optimization problem with a rather arbitrary objective function.
%The objective function can help the solver by destroying the inherent 
%symmetry of the problem.

sudpuzzle = optimproblem;
mul = ones(1,1,9);
mul = cumsum(mul,3);
sudpuzzle.Objective = sum(sum(sum(x,1),2).*mul);

%Represent the constraints that the sums of x in each coordinate direction are one.
sudpuzzle.Constraints.consx = sum(x,1) == 1;
sudpuzzle.Constraints.consy = sum(x,2) == 1;
sudpuzzle.Constraints.consz = sum(x,3) == 1;

%Create the constraints that the sums of the major grids sum to one as well.
majorg = optimconstr(3,3,9);

for u = 1:3
    for v = 1:3
        arr = x(3*(u-1)+1:3*(u-1)+3,3*(v-1)+1:3*(v-1)+3,:);
        majorg(u,v,:) = sum(sum(arr,1),2) == ones(1,1,9);
    end
end
sudpuzzle.Constraints.majorg = majorg;

%Include the initial clues by setting lower bounds of 1 at the clue entries.
%This setting fixes the value of the corresponding entry to be 1, and so 
%sets the solution at each clued value to be the clue entry.

for u = 1:size(B,1)
    x.LowerBound(B(u,1),B(u,2),B(u,3)) = 1;
end

%Solve the Sudoku puzzle.
sudsoln = solve(sudpuzzle)

%Round the solution to ensure that all entries are integers, and display 
%the solution.
sudsoln.x = round(sudsoln.x);

y = ones(size(sudsoln.x));
for k = 2:9
    y(:,:,k) = k; % multiplier for each depth k
end

S = sudsoln.x.*y; % multiply each entry by its depth
S = sum(S,3); % S is 9-by-9 and holds the solved puzzle
drawSudoku(S)