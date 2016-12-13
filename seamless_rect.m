function final_img = seamless_rect(y1,y2)
% y1 = imread('nabla_f.png');
% y2 = imread('wall.jpg');
[m, n, x] = size(y1);
mask =  zeros(m,n);
mask(2:m-1,2:n-1) = 1;

%% Find the size of the Cooefficient_matr
num_points = nnz(mask);
I = zeros(num_points,1);
J = zeros(num_points,1);
%% Create the X,Y coordinates vectors and the index vector

count=1;
for i=1:m
    for j=1:n
        if mask(i,j)==1
            I(count) = i;
            J(count) = j;
            count = count+1;
        end
    end
end

index_matr = zeros(m,n);
count = 1;

for i = 1:num_points
   y = I(i);
   x = J(i);
   index_matr(y,x) = count;
   count = count + 1;
end

%% calculate laplacian at each point in source image

y1 = double(y1);
H = [0 -1 0; -1 4 -1; 0 -1 0];
grad_img = imfilter(y1,H);

%% Initialise the A and B matrices
Coeff_matr = spalloc(num_points,num_points,5*num_points);

B = zeros(num_points,3);

%% Fill the A matrix
for y = 2:m-1
    for x = 2:n-1
        % only add points that are in mask
        if mask(y,x) == 1
            neighbours = 1;
            % take care of neighbors
            % top boundary
            if   mask(y-1,x) == 1
                Coeff_matr(index_matr(y,x),index_matr(y-1,x)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(y2(y-1,x,chnl));
                end
            end
            
            % left boundary
                if mask(y,x-1) == 1
                Coeff_matr(index_matr(y,x),index_matr(y,x-1)) = -1;
                neighbours = neighbours+1;
            else
                for chnl =1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(y2(y,x-1,chnl));
                end
                end
            
            % bottom boundary
                if mask(y+1,x) == 1
                Coeff_matr(index_matr(y,x),index_matr(y+1,x)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(y2(y+1,x,chnl));
                end
                end
            
            % right boundary
                if mask(y,x+1) == 1
                Coeff_matr(index_matr(y,x),index_matr(y,x+1)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(y2(y ,x+1,chnl));
                end
                end
            
            for  chnl =1:3
                B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + grad_img(y,x,chnl);
            end
            Coeff_matr(index_matr(y,x),index_matr(y,x)) = 4;
        end
    end
end
%% solving AX=B

final_img = double(y2);

solns = Coeff_matr\B;
for k = 1:num_points
    final_img(I(k),J(k),:) = solns(k,:);
end
%% Outputs
final_img = uint8(final_img);
% figure,imshow(final_img);

end