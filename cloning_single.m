clear all;
close all;
%% Inputs 
background_img = imread('images/text.jpg');
border_img = imread('images/wall.jpg');
%background_img = imresize(background_img,0.5);
% border_img = imresize(border_img,0.5);
[m, n, x] = size(background_img);
%% Select area in the background image

f1 = figure;
imshow(background_img);
h = imfreehand;
api = iptgetapi(h)
fcn = makeConstrainToRectFcn('imfreehand',[1 size(background_img,2)],[1 size(background_img,1)]);
api.setPositionConstraintFcn(fcn);
position = wait(h);
mask = double(createMask(h));
close(f1);
%% Crop the background image and set the border of mask as 0

cc = regionprops(mask,'BoundingBox');
mask = imcrop(mask,cc(1).BoundingBox);
mask(1,:) = 0;
mask(end,:) = 0;
mask(:,1) = 0 ;
mask(:,end) = 0;
background_img = imcrop(background_img,cc(1).BoundingBox);
[m, n, x] = size(background_img);
% figure,imshow(background_img);
% figure,imshow(mask);
%% Select the area in the target image and resize the background image


f3 = figure;
% subplot(1,2,1);
% imshow(background_img),hold on;
% plot(position(:,1),position(:,2))
% subplot(1,2,2);
imshow(border_img);
h2 = imrect(gca,[1 1 size(mask,2) size(mask,1)]);
setFixedAspectRatioMode(h2,1);
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h2,fcn); 
position2 = wait(h2);
close(f3);

mask = imresize(mask,[position2(4) position2(3)]);
mask = mask > 0;
background_img = imresize(background_img,[position2(4) position2(3)]);
mask(1,:) = 0;
mask(end,:) = 0;
mask(:,1) = 0 ;
mask(:,end) = 0;
[m, n, x] = size(background_img);
%% Row shift and col shift


row_shift = floor(position2(2));
col_shift = floor(position2(1));

%% Create the X,Y coordinates vectors and the index vector


num_points = nnz(mask); % size of Coeff Matrix
I = zeros(num_points,1);
J = zeros(num_points,1);

count=1;
for i=1:m
    for j=1:n
        if mask(i,j) == 1
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

background_img = double(background_img);
H = [0 -1 0; -1 4 -1; 0 -1 0];
grad_img = imfilter(background_img,H);

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
            if mask(y-1,x) == 1
                Coeff_matr(index_matr(y,x),index_matr(y-1,x)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(border_img(y-1+row_shift,x+col_shift,chnl));
                end
            end
            
            % left boundary
            if mask(y,x-1) == 1
                Coeff_matr(index_matr(y,x),index_matr(y,x-1)) = -1;
                neighbours = neighbours+1;
            else
                for chnl =1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(border_img(y+row_shift,x-1+col_shift,chnl));
                end
            end
            
            % bottom boundary
            if mask(y+1,x) == 1
                Coeff_matr(index_matr(y,x),index_matr(y+1,x)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(border_img(y+1+row_shift ,x+col_shift,chnl));
                end
            end
            
            % right boundary
            if mask(y,x+1) == 1
                Coeff_matr(index_matr(y,x),index_matr(y,x+1)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + double(border_img(y + row_shift ,x+1+col_shift,chnl));
                end
            end
            
            for  chnl =1:3
                B(index_matr(y,x),chnl) = B(index_matr(y,x),chnl) + grad_img(y,x,chnl);
            end
            Coeff_matr(index_matr(y,x),index_matr(y,x)) = 4;
        end
    end
end
%% Solving AX = B

final_img = double(border_img);
solns = Coeff_matr\B;
for k = 1:num_points
    final_img(I(k)+row_shift,J(k)+col_shift,:) = solns(k,:);
end
%% Outputs

final_img = uint8(final_img);
figure,imshow(final_img);