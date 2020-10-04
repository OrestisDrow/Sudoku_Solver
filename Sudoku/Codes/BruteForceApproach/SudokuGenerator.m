%% Make some Sudokus!!!

% You must be in the Sudoku directory for this to work.
%
% This code will try to produce the hardest Sudoku it can. Since the
% solution is given, you can always make the Sudoku easier by filling in
% several squares. The solution given is guaranteed to be the ONLY
% solution.
%
% This code can sometimes spend 10 seconds on a single Sudoku (I would
% think that if a terribly difficult Sudoku is being created, this code can
% spend an entire minute on it). Progress messages will start to be shown
% if the Sudoku is not created after 30 seconds. When the entire code is
% finished making every Sudoku, MATLAB will beep.
%
% Pressing "ctrl-c" at the command window works to stop the code if you
% don't want to wait for it to finish. If "record=1;" you should probably
% also run the command "diary off".
%
% The output Sudoku is not only given in standard format but also given in
% one-line format so that http://www.sudokuwiki.org/sudoku.htm can easily
% be used.
%
% The outputs called "depth of thread" and "number of guesses" are
% explained in SudokuSolver.m.
%
% (c) 2008 Bradley Knockel

%% parameters for you to set

% How many Sudokus do you want to make? If you are using MATLAB, more than
% 100 can overflow the command window making the results of the first runs
% unable to be viewed.
N=1;


% choose the symmetry of the puzzle (will most likely prevent the hardest
% Sudokus from being made, especially as the number increases)
%     0 - no symmetry
%     1 - symmetry with respect to x-axis
%     2 - symmetry with respect to y-axis
%     3 - symmetry with respect to the origin
%     4 - symmetries 1, 2, and 3
%     5 - symmetry with respect to 90 degree rotations (implies symmetry 3)
%     6 - symmetries 1 through 5
s=0;


% set randomSolution to 1 to generate a random solution (else 0)
randomSolution=1;


% make a solution to be used if randomSolution=0
solution=[
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0
    0,0,0,0,0,0,0,0,0];


% Set record to 1 to create (or append to) a file called "diary" that will
% contain all the output of this code (else 0). This can be useful if
% creating a very large number of Sudokus.
record=0;


% If you know the seed of a good Sudoku, put it here and it will be run.
% Make sure that "seed=-1;" if a seed set by the clock is to be used.
% When using a seed, the value of "N" is irrelevant.
% You can also do multiple seeds like this:
%     "seed=[4,6,123456789];" or
%     "seed=[0:3,50,1e8:1e8+2];"
% A seed should be a non-negative integer not bigger than
%     2^32-1 = 4294967295.
seed=-1;
% For the case that "s=0;" and "randomSolution=1;" and you are using a
%     version of MATLAB similar to R2006b, some good seeds are:
%     [288392389, 504931541, 1150370547, 1216082493, 2856429349]
% Note: Windows R2006b, Linux R2009b, and Mac R2011b give same results for
%     these seeds.
% Rerunning a seed cannot change "depth of thread" or "number of guesses"
%     values. You must instead copy the Sudoku into SudokuSolver.m.


%% time to actually make the Sudoku(s)

if record
    diary on
end

if any(seed<0)
    n=floor(rem(now,1)*2e9)+2e9;
    for i=1:N
        disp(['************************** iteration ',int2str(i),' **************************'])
        [solution,sudoku]=suma(randomSolution,solution,n,-1,s)
        sudokuString=mat2str(sudoku);
        sudokuString=strrep(sudokuString,' ','');
        sudokuString=strrep(sudokuString,';','');
        sudokuString=strrep(sudokuString,'[','');
        sudokuString=strrep(sudokuString,']','');
        sudokuString=strrep(sudokuString,',','');
        disp(sudokuString)
    end
else
    for seed=(seed(:)')
        disp('************************************************************************')
        [solution,sudoku]=suma(randomSolution,solution,0,seed,s)
        sudokuString=mat2str(sudoku);
        sudokuString=strrep(sudokuString,' ','');
        sudokuString=strrep(sudokuString,';','');
        sudokuString=strrep(sudokuString,'[','');
        sudokuString=strrep(sudokuString,']','');
        sudokuString=strrep(sudokuString,',','');
        disp(sudokuString)
    end
end

if record
    diary off
end

beep
clear all