function func = sparse3Dfrom2Dfull(fullmatrix)
%Function to produce the 2D puzzle from the binary 3D puzzle
    if any(size(fullmatrix))~=9
    	func = 0;
    end
    [i,j,k] = find(fullmatrix);
    func = [i,j,k];
end
