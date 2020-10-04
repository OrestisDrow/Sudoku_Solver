clear;
clc;

%Making some test clue puzzles to try them out
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

matrix3=[
    8,5,0,0,0,2,4,0,0
    7,2,0,0,0,0,0,0,9
    0,0,4,0,0,0,0,0,0
    0,0,0,1,0,7,0,0,2
    3,0,5,0,0,0,9,0,0
    0,4,0,0,0,0,0,0,0
    0,0,0,0,8,0,0,7,0
    0,1,7,0,0,0,0,0,0
    0,0,0,0,3,6,0,4,0];
%plotcube([9 9 9],[0 0 0],0.1,[0 1 0]);



matrix4=[
    1,0,0,0,0,7,0,9,0
    0,3,0,0,2,0,0,0,8
    0,0,9,6,0,0,5,0,0
    0,0,5,3,0,0,9,0,0
    0,1,0,0,8,0,0,0,2
    6,0,0,0,0,4,0,0,0
    3,0,0,0,0,0,0,1,0
    0,4,0,0,0,0,0,0,7
    0,0,7,0,0,0,3,0,0];

B = sparse3Dfrom2Dfull(matrix4);
drawSudoku(B)

x = optimvar('x',9,9,9,'Type','integer','LowerBound',0,'UpperBound',1);

%Setting the optimization problem
sudpuzzle = optimproblem;
mul = ones(1,1,9);
mul = cumsum(mul,3);
sudpuzzle.Objective = sum(sum(sum(x,1),2).*mul);

%Constraints
sudpuzzle.Constraints.consx = sum(x,1) == 1;    %x-axis constraint
sudpuzzle.Constraints.consy = sum(x,2) == 1;    %y-axis constraint
sudpuzzle.Constraints.consz = sum(x,3) == 1;    %z-axis constraint
majorg = optimconstr(3,3,9);                    %x-y-axis constraint

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
sudsoln.x = round(sudsoln.x);

%Reducing the 9x9x9(binary 0->1) matrix to 9x9(0->9)
y = ones(size(sudsoln.x));
for k = 2:9
    y(:,:,k) = k;
end

S = sudsoln.x.*y; % multiply each entry by its depth
S = sum(S,3); % S is 9-by-9 and holds the solved puzzle

drawSudoku(S)

