function [endstate,mat,big]=suan(big,mat,go)

%
%function used within su.m
%
% (c) 2008 Bradley Knockel

%this function attempts to solve the Sudoku without guesswork

%endstate=
%0 if Sudoku is unsolved
%1 if Sudoku is solved

%go=
%0 if simple algorithm is to be used
%1 if more complex algorithm is to be used

temp=zeros(9,9,9)-1;
while any(any(any(temp~=big)))
    temp=big;  %"temp" is used to determine if an iteration changes "big"
    for b=1:9
        for c=1:9



            rowbox=3*rem((c-1),3)+1;   %1,4,7,1,4,7,1,4,7
            colbox=3*floor((c-1)/3)+1; %1,1,1,4,4,4,7,7,7

            %columns  (b is number; c is column)
            d=sort(big(:,c,b),'descend');
            if d(2)==0 && d(1)
                index=find(big(:,c,b))+9*(c-1);
                big=sufu(index,b,big);
                mat(index)=b;
            end

            %rows  (b is number; c is row)
            d=sort(big(c,:,b),'descend');
            if d(2)==0 && d(1)
                index=c+9*(find(big(c,:,b))-1);
                big=sufu(index,b,big);
                mat(index)=b;
            end

            %boxes  (b is number; c is box)
            d=find(big((rowbox:rowbox+2),(colbox:colbox+2),b));
            if all(size(d)==[1,1])
                [rowINbox,colINbox]=ind2sub([3,3],d);
                index=((rowbox-1)+rowINbox)+9*((colbox-1)+(colINbox-1));
                big=sufu(index,b,big);
                mat(index)=b;
            end

            %lone number search  (b is row; c is column)
            d=sort(big(b,c,:),3,'descend');
            if d(1) && d(2)==0
                index=sub2ind([9,9],b,c);
                big=sufu(index,d(1),big);
                mat(index)=d(1);
            end
            
            
            
            % Get the big guns (3 of them). These guns are very
            % complicated, so I will not explain how they work.
            if go   %none of these methods alter "mat," but they alter "big"

                %This trick has to do with the interaction between a box
                %and a row or column. (b is number)
                d=find(big((rowbox:rowbox+2),(colbox:colbox+2),b)); %box affecting row or column (c is box)
                if length(d)==2 || length(d)==3
                    [a1,a2]=ind2sub([3,3],d);
                    if all(a1==a1(1)) %row
                        row=(rowbox-1)+a1(1);
                        big(row,:,b)=0;
                        big(row,(colbox-1)+a2,b)=b;
                    elseif all(a2==a2(1)) %column
                        col=(colbox-1)+a2(1);
                        big(:,col,b)=0;
                        big((rowbox-1)+a1,col,b)=b;
                    end
                end
                d=find(big(c,:,b)); %row affecting box (c is row)
                if (length(d)==2 || length(d)==3) && all(floor((d-1)/3)==ones(size(d))*floor((d(1)-1)/3))
                    a=sub2ind([9,9],c*ones(size(d)),d);
                    box=floor(((a(1)-9*(d(1)-1))-1)/3)+1+3*floor((d(1)-1)/3);
                    d=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D linear index of upper left square
                    i=[d:d+2,d+9:d+11,d+18:d+20]';
                    for j=a(:)'
                        i(i==j)=[];
                    end
                    big(i+81*(b-1))=0;
                end
                d=find(big(:,c,b)); %column affecting box (c is column)
                if (length(d)==2 || length(d)==3) && all(floor((d-1)/3)==ones(size(d))*floor((d(1)-1)/3))
                    a=sub2ind([9,9],d,c*ones(size(d)));
                    box=floor(((a(1)-9*(c-1))-1)/3)+1+3*floor((c-1)/3);
                    d=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D linear index of upper left square
                    i=[d:d+2,d+9:d+11,d+18:d+20]';
                    for j=a(:)'
                        i(i==j)=[];
                    end
                    big(i+81*(b-1))=0;
                end
                
                
                %naked pair (b is a number; c is another number)
                if b>c
                    a=find(big(:,:,b) & big(:,:,c) & sum(big~=0,3)==2);
                    if length(a)>=2
                        [a1,a2]=ind2sub([9,9],a);
                        a3=floor(((a-9*(a2-1))-1)/3)+1+3*floor((a2-1)/3); %box number
                        if any(diff(sort(a1))==0) %row
                            bla1=sort(a1);
                            rows=bla1(diff(bla1)==0);
                            for row=rows'
                                cols=1:9;
                                cols(a2(a1==row))=[];
                                big(row,cols,[b,c])=0;
                            end
                        end
                        if any(diff(sort(a2))==0) %column
                            bla2=sort(a2);
                            cols=bla2(diff(bla2)==0);
                            for col=cols'
                                rows=1:9;
                                rows(a1(a2==col))=[];
                                big(rows,col,[b,c])=0;
                            end
                        end
                        if any(diff(sort(a3))==0) %box
                            bla=sort(a3);
                            boxes=bla(diff(bla)==0);
                            for box=boxes'
                                d=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D linear index of upper left square
                                i=[d:d+2,d+9:d+11,d+18:d+20]';
                                for j=a(a3==box)'
                                    i(i==j)=[];                 %all indices that need to be adjusted
                                end
                                big([i+81*(b-1),i+81*(c-1)])=0;
                            end
                        end
                    end
                end

                %hidden pair (b is a number; c is another number)
                if b>c
                    a=find(big(:,:,b) & big(:,:,c));
                    if length(a)>=2
                        [a1,a2]=ind2sub([9,9],a);
                        a3=floor(((a-9*(a2-1))-1)/3)+1+3*floor((a2-1)/3); %box number
                        if any(diff(sort(a1))==0) %row
                            bla1=sort(a1);
                            rows=bla1(diff(bla1)==0);
                            for row=rows'
                                if length(find(big(row,:,b)==b))==2 && length(find(big(row,:,c)==c))==2
                                    depths=1:9;
                                    depths([b,c])=[];
                                    big(row,a2(a1==row),depths)=0;
                                end
                            end
                        end
                        if any(diff(sort(a2))==0) %column
                            bla2=sort(a2);
                            cols=bla2(diff(bla2)==0);
                            for col=cols'
                                if length(find(big(:,col,b)==b))==2 && length(find(big(:,col,c)==c))==2
                                    depths=1:9;
                                    depths([b,c])=[];
                                    big(a1(a2==col),col,depths)=0;
                                end
                            end
                        end
                        if any(diff(sort(a3))==0) %box
                            bla=sort(a3);
                            boxes=bla(diff(bla)==0);
                            for box=boxes'
                                d=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D index of upper left square
                                i=[d:d+2,d+9:d+11,d+18:d+20]';
                                if length(find(big(i+81*(b-1))==b))==2 && length(find(big(i+81*(c-1))==c))==2
                                    [A1,A2]=ind2sub([9,9],a(a3==box));
                                    depths=1:9;
                                    depths([b,c])=[];
                                    for i=1:2
                                        big(A1(i),A2(i),depths)=0;
                                    end
                                end
                            end
                        end
                    end
                end

            end


            % Let's do 2 more tricks. These involve finding triplets.
            if go  %none of these methods alter "mat," but they alter "big"
                for d=1:7 %a, b, and c, will all be numbers (not boxes or whatever)
                    if d<c && c<b

                        %naked triplets
                        l=1:9;
                        l([b,c,d])=[];
                        grid=(big(:,:,b)|big(:,:,c)|big(:,:,d))&...
                            ~big(:,:,l(1))&~big(:,:,l(2))&~big(:,:,l(3))...
                            &~big(:,:,l(4))&~big(:,:,l(5))&~big(:,:,l(6));
                        a=find(grid);
                        if length(a)>=3
                            [a1,a2]=ind2sub([9,9],a);
                            a3=floor(((a-9*(a2-1))-1)/3)+1+3*floor((a2-1)/3); %box number
                            if any(sum(grid,2)==3) %row
                                rows=find(sum(grid,2)==3);
                                for row=rows'
                                    cols=1:9;
                                    cols(a2(a1==row))=[];
                                    big(row,cols,[b,c,d])=0;
                                end
                            end
                            if any(sum(grid,1)==3) %column
                                cols=find(sum(grid,1)==3);
                                for col=cols
                                    rows=1:9;
                                    rows(a1(a2==col))=[];
                                    big(rows,col,[b,c,d])=0;
                                end
                            end
                            blob=sort(a3);
                            bla=~diff(blob)&~[diff(diff(blob));1];
                            if any(bla) %box
                                boxes=blob(bla);
                                for box=boxes(:)'
                                    e=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D index of upper left square
                                    i=[e:e+2,e+9:e+11,e+18:e+20]';
                                    for j=a(a3==box)'
                                        i(i==j)=[];                 %all 2D indices that need to be adjusted
                                    end
                                    big([i+81*(b-1),i+81*(c-1),i+81*(d-1)])=0;
                                end
                            end
                        end

                        %hidden triplets
                        grid=sum(big(:,:,[b,c,d])~=0,3)>=2;
                        a=find(grid);
                        if length(a)>=3
                            [a1,a2]=ind2sub([9,9],a);
                            a3=floor(((a-9*(a2-1))-1)/3)+1+3*floor((a2-1)/3); %box number
                            if any(sum(grid,2)==3) %row
                                rows=find(sum(grid,2)==3);
                                for row=rows(:)'
                                    cols=1:9;
                                    cols0=a2(a1==row);
                                    cols(cols0)=[];
                                    if all(all(big(row,cols,[b,c,d])==0))&&any(big(row,cols0,b))&&any(big(row,cols0,c))&&any(big(row,cols0,d))
                                        depths=1:9;
                                        depths([b,c,d])=[];
                                        big(row,cols0,depths)=0;
                                    end
                                end
                            end
                            if any(sum(grid,1)==3) %column
                                cols=find(sum(grid,1)==3);
                                for col=cols(:)'
                                    rows=1:9;
                                    rows0=a1(a2==col);
                                    rows(rows0)=[];
                                    if all(all(big(rows,col,[b,c,d])==0))&&any(big(rows0,col,b))&&any(big(rows0,col,c))&&any(big(rows0,col,d))
                                        depths=1:9;
                                        depths([b,c,d])=[];
                                        big(rows0,col,depths)=0;
                                    end
                                end
                            end
                            boxes=[];
                            for j=1:9
                                if length(a3(a3==j))==3
                                    boxes=[boxes,j];
                                end
                            end
                            for box=boxes(:)'
                                e=3*floor((box-1)/3)*9+3*rem((box-1),3)+1; %2D linear index of upper left square
                                i=[e:e+2,e+9:e+11,e+18:e+20]';
                                for j=a(a3==box)'
                                    i(i==j)=[];
                                end
                                if all(all(big([i+81*(b-1);i+81*(c-1);i+81*(d-1)])==0))&&...
                                        any(big(a(a3==box)+81*(b-1)))&&any(big(a(a3==box)+81*(c-1)))&&any(big(a(a3==box)+81*(d-1)))
                                    [A1,A2]=ind2sub([9,9],a(a3==box));
                                    depths=1:9;
                                    depths([b,c,d])=[];
                                    for j=1:3
                                        big(A1(j),A2(j),depths)=0;
                                    end
                                end
                            end
                        end

                        
                    end
                end
            end


        end
    end
end

if (mat==0)==zeros(9)
    endstate=1;
else
    endstate=0;
end