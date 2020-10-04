function big=sufu(c,number,big)

%
%function used within su.m
%
% (c) 2008 Bradley Knockel

%this function removes numbers from "big"

%"number" is the number in the square

%a-e describe a square on the Sudoku puzzle
%a is the row (1-9)
%b is the column (1-9)
%c is the index (1-81)
%d is the box row (1,4,7)
%e is the box column (1,4,7)

[a,b]=ind2sub([9,9],c);
big(a,:,number)=0; %rows
big(:,b,number)=0; %columns
d=3*floor((a-1)/3)+1;
e=3*floor((b-1)/3)+1;
big((d:d+2),(e:e+2),number)=0; %boxes
big(a,b,:)=0; %square