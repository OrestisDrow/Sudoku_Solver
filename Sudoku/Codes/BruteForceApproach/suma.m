function [solution,sudoku]=suma(randomSolution,solution,n,seed,s)

%
%function used by SudokuMaker.m
%
% (c) 2008 Bradley Knockel

%% do some basic stuff

now0=cputime;

TimeLimits=[5,1e50,1e50];  % do not change these!!! (measured in seconds)
% first value is the time limit for creating "mat"
% second value is the time limit for running "su.m" on "mat"
% third value is the time limit for running "su.m" on "sudoku"

if seed==-1
    seed=floor(n*rand);
end
try %the new way to set seeds
    RandStream.setDefaultStream(RandStream('swb2712','Seed',seed));
catch %the way that is deprecated
    rand('state',seed);
end
disp(['suma.m comment: seed is ',int2str(seed)])

%% form the solution
%The following creates a matrix called "mat" that hopes to be solvable by
%"su.m". This process will keep happening until a good "mat" is formed.

if randomSolution

    b=1;
    while b

        %%%%% first, we start with a blank matrix
        mat=zeros(9);

        %%%%% now, I create 3 random 3x3 boxes and put them along the diagonal of mat
        for i=[0,3,6]
            y=randperm(9);
            mat(1+i,1+i:3+i)=y(1:3);
            mat(2+i,1+i:3+i)=y(4:6);
            mat(3+i,1+i:3+i)=y(7:9);
        end

        %%%%% now, I fill in the first row randomly
        w=1;
        while w    %"w" will equal 0 when a valid first row is formed
            y=zeros(1,9);
            y(1:3)=mat(1,[1,2,3]);  %"y" will become the values of the first row
            choices=1:9;
            choices(mat(1,[1,2,3]))=0; %"choices" is the default list of valid numbers
            for i=4:9
                if i>=7
                    j=3;
                else
                    j=0;
                end
                choice=choices;
                choice(mat(4+j:6+j,i))=0;
                choice(choice==0)=[]; %"choice" is the current list of valid numbers
                n=length(choice);
                if n==0  %if there are no valid choices, restart the process
                    break
                end
                x=floor(rand*n)+1; %"x" is which choice to use for the square
                a=choice(x);
                y(i)=a;
                choices(a)=0;
            end
            if not(any(y==0))
                w=0;
            end
        end
        mat(1,:)=y;

        %%%%% now, I do the same with the first column
        w=1;
        while w
            y=zeros(9,1);
            y(1:3)=mat([1,2,3],1);
            choices=(1:9)';
            choices(mat([1,2,3],1))=0;
            for i=4:9
                if i>=7
                    j=3;
                else
                    j=0;
                end
                choice=choices;
                choice(mat(i,4+j:6+j))=0;
                choice(choice==0)=[];
                n=length(choice);
                if n==0
                    break
                end
                x=floor(rand*n)+1;
                a=choice(x);
                y(i)=a;
                choices(a)=0;
            end
            if not(any(y==0))
                w=0;
            end
        end
        mat(:,1)=y;

        %%%%% now, I randomly fill in the last column
        w=1;
        now1=cputime;
        while w
            if cputime-now1>TimeLimits(1)  % there is a chance that no valid column can be produced
                disp('suma.m comment: A time limit has been reached. There is a VERY low chance reusing this seed will produce different results.')
                disp(['suma.m comment: total elapsed time is ',num2str(cputime-now0,'%.4f'),' seconds'])
                solution=[];sudoku=[];
                return
            end
            y=mat(:,9);
            choices=(1:9)';
            choices(mat([1,7,8,9],9))=0;
            for i=2:6
                choice=choices;
                if i>=4
                    choice(mat(i,[1,4:6]))=0;
                else
                    choice(mat(i,1:3))=0;
                    choice(mat(1,7:8))=0;
                end
                choice(choice==0)=[];
                n=length(choice);
                if n==0
                    break
                end
                x=floor(rand*n)+1;
                a=choice(x);
                y(i)=a;
                choices(a)=0;
            end
            if not(any(y==0))
                w=0;
            end
        end
        if w==0
            mat(:,9)=y;
        end

        %%%%% I now try to randomly fill everything else with su.m
        a=su(mat,TimeLimits(2),0,0,0);
        if size(a)~=1
            solution=a;
            b=0;
        end

    end
    
else
    
    if any(any(solution==0))
        disp('suma.m error: invalid solution provided')
        return
    end
    
    a=su(solution,0,0,0,0);
    if all(size(a)==[9,9])
        solution=a;
    else
        disp('suma.m error: invalid solution provided')
        return
    end
    
end

disp('suma.m comment: Valid solution obtained. Now creating Sudoku...')

%% form the Sudoku from solution
%This part randomly cycles through all 81 squares of the solution and 
%simply creates a blank if doing so does not create an underdetermined
%Sudoku.

sudoku=solution;
n=0; %number of blanks (unknowns) in sudoku
if s==0
    j=81;
    choices=1:81;
elseif s==1
    j=45;
    choices=[1:4,10:13,19:22,28:31,37:40,46:49,55:58,64:67,73:76];
elseif s==2
    j=45;
    choices=1:34;
elseif s==3
    j=41;
    choices=1:40;
elseif s==4
    j=25;
    choices=[1:4,10:13,19:22,28:31];
    q=1;
elseif s==5
    j=21;
    choices=[1:5,10:14,19:23,28:32];
else
    j=15;
    choices=[10,19,20,28:30];
    q=1;
end
for i=1:j

    %%%% randomly choose a square on the 9x9 sukoku that is not blank
    a=length(choices);
    if cputime-now0>30
        fprintf(1,'suma.m progress: %g out of %g cycles have been completed (%g filled squares)\n',81-a,j,81-n)
    end
    y=floor(rand*a)+1;
    x=choices(y);  %square to be analyzed
    choices(y)=[];
    
    %%%% check if symmetry requires other squares to be simultaneously analyzed
    [r,c]=ind2sub([9,9],x);
    if s==0
        %nothing to do
    elseif s==1
        if r~=5,x=[x,sub2ind([9,9],10-r,c)];end
        if isempty(choices),choices=[5,14,23,32,41,50,59,68,77];end
    elseif s==2
        if c~=5,x=[x,sub2ind([9,9],r,10-c)];end
        if isempty(choices),choices=37:45;end
    elseif s==3
        if x~=41,x=[x,sub2ind([9,9],10-r,10-c)];end
        if isempty(choices),choices=41;end
    elseif s==4
        if r~=5,x=[x,sub2ind([9,9],10-r,c)];end
        if c~=5,x=[x,sub2ind([9,9],r,10-c)];end
        if r~=5&&c~=5,x=[x,sub2ind([9,9],10-r,10-c)];end
        if isempty(choices)
            choices=41;
            if q==1,choices=[5,14,23,32,37:40];end
            q=0;
        end
    elseif s==5
        if x~=41,x=[x,sub2ind([9,9],10-r,10-c),sub2ind([9,9],c,10-r),sub2ind([9,9],10-c,r)];end
        if isempty(choices),choices=41;end
    else
        if q==1,x=[x,sub2ind([9,9],10-r,10-c),sub2ind([9,9],c,10-r),sub2ind([9,9],10-c,r),sub2ind([9,9],10-c,10-r),sub2ind([9,9],10-r,c),sub2ind([9,9],c,r),sub2ind([9,9],r,10-c)];end
        if q==0,x=[x,sub2ind([9,9],10-r,10-c),sub2ind([9,9],c,10-r),sub2ind([9,9],10-c,r)];end
        if isempty(choices)
            choices=41;
            if q==1,choices=[1,11,21,31,37:40];end
            q=q-1;
        end
    end
    
    %%%% check if removing the squares is acceptable and, if so, remove them
    values=sudoku(x);
    sudoku(x)=0;
    [a,ud]=su(sudoku,TimeLimits(3),0,1,0);
    if  ud==0   %"ud" equals 0 if "sudoku" is not underdetermined
        n=n+length(x);
    else
        sudoku(x)=values;
    end
    
end

disp('suma.m comment: finished making Sudoku!')
disp(['suma.m comment: total elapsed time is ',num2str(cputime-now0,'%.4f'),' seconds'])
disp(['suma.m comment: number of filled squares is ',int2str(81-n)])
disp('suma.m comment: calling su.m to get some info on how difficult the Sudoku is...')
su(sudoku,1e10,1,0,1);