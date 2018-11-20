%% Inputs 
background_img = imread('imgs/src-2.png');
border_img = imread('imgs/dest-2.png');
% background_img = imread('imgs/src-2.png');
% border_img = imread('imgs/dest-2.png');
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
num_pixels = nnz(mask);
I = zeros(num_pixels,1);
J = zeros(num_pixels,1);

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
for i = 1:num_pixels
   k = I(i);
   j = J(i);
   index_matr(k,j) = count;
   count = count + 1;
end


%% Initialise the A and B matrices
border_img = double(border_img);
background_img = double(background_img);

Coeff_matr = spalloc(num_pixels,num_pixels,5*num_pixels);
B = zeros(num_pixels,3);

%% Fill the A matrix
for i = 2:m-1
    for j = 2:n-1
        if mask(i,j) == 1
            %calculate number of valid neighbours for each pixel
            neighbours=1;
        if mask(i,j) == 1            
            % top boundary
            if mask(i-1,j) == 1
                Coeff_matr(index_matr(i,j),index_matr(i-1,j)) = -1;
                neighbours=neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl)+(border_img(i-1+row_shift,j+col_shift,chnl));
                end
            end
            
        % left boundary
            if mask(i,j-1) == 1
                Coeff_matr(index_matr(i,j),index_matr(i,j-1)) = -1;
                neighbours = neighbours+1;
            else
                 for chnl=1:3
                    B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + (border_img(i+row_shift,j-1+col_shift,chnl));
                end
            end
            
        % bottom boundary
            if mask(i+1,j) == 1
                Coeff_matr(index_matr(i,j),index_matr(i+1,j)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + (border_img(i+1+row_shift,j+col_shift,chnl));
                end
            end
            
        % right boundary
            if mask(i,j+1) == 1
                Coeff_matr(index_matr(i,j),index_matr(i,j+1)) = -1;
                neighbours = neighbours+1;
            else
                for chnl=1:3
                    B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + (border_img(i+row_shift,j+1+col_shift,chnl));
                end
            end
            Coeff_matr(index_matr(i,j),index_matr(i,j))=4;
            
            % find the maximum gradient at any point of (backgroundimage,borderimage)
            for dir_grad= -1:2:1
                for chnl = 1:3
                    %y gradients
                    num1 = border_img(i+row_shift,j+col_shift,chnl)-border_img(i-dir_grad+row_shift,j+col_shift,chnl);
                    num2 = background_img(i,j,chnl) - background_img(i-dir_grad,j,chnl);
                    if abs(num1) > abs(num2)
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + num1;
                    else
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + num2;
                    end
                    %x gradients
                    num1 = (border_img(i+row_shift,j+col_shift,chnl)-border_img(i+row_shift,j-dir_grad+col_shift,chnl));
                    num2 = (background_img(i,j,chnl) - background_img(i,j-dir_grad,chnl));
                    if abs(num1) > abs(num2)
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + num1;
                    else
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + num2;
                    end
                    
                end         
            end
        end
    end
end
%% Solving AX = B
final_img = double(border_img);
solns = Coeff_matr\B;

for chnl = 1:3
    for k = 1:num_pixels
        final_img(I(k)+row_shift,J(k)+col_shift,chnl) = solns(k,chnl);
    end
end

%% Outputs
final_img = uint8(final_img);
figure,imshow(final_img);