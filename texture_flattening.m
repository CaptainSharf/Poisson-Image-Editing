border_img = imread('boy.jpg');
figure,imshow(border_img);
h = imfreehand;
position = wait(h);
mask = double(createMask(h));
gray_img = rgb2gray(border_img);
edge_img = edge(gray_img,'canny');
[m, n, j] = size(border_img);

H = [0 -1 0; -1 4 -1; 0 -1 0];
border_img = double(border_img);
grad_img = imfilter(border_img,H);

num_pixels = nnz(mask);
I = zeros(num_pixels);
J = zeros(num_pixels);

index_matr = zeros(m,n);
count=1;
for i=1:m
    for j=1:n
        if mask(i,j)==1
            I(count) = i;
            J(count) = j;
            index_matr(i,j) = count;
            count = count+1;
        end
    end
end

% create sparse matrix for each pixel
Coeff_matr = spalloc(num_pixels,num_pixels,5*num_pixels);
B = zeros(num_pixels,3);

for i = 2:m-1
    for j = 2:n-1
        if mask(i,j) == 1
            
            for delta = -1:2:1
                if mask(i,j+delta) == 1
                    Coeff_matr(index_matr(i,j),index_matr(i,j+delta)) = -1; 
                else
                    for chnl=1:3
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + double(border_img(i,j+delta,chnl));
                    end
                end
                
                if mask(i+delta,j) == 1
                    Coeff_matr(index_matr(i,j),index_matr(i+delta,j)) = -1;
                else
                    for chnl = 1:3
                        B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + double(border_img(i+delta,j,chnl));
                    end
                end
                
            end
            
  
            if edge_img(i,j) == 1
                for chnl=1:3
                    B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + double(grad_img(i,j,chnl));
                end
            else
                for delta=-1:2:1
                    if edge_img(i+delta,j) == 1
                        for chnl=1:3
                            B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + border_img(i,j,chnl) - border_img(i+delta,j,chnl);
                        end
                    end
                    
                    if edge_img(i,j+delta) == 1
                        for chnl=1:3
                            B(index_matr(i,j),chnl) = B(index_matr(i,j),chnl) + border_img(i,j,chnl) - border_img(i,j+delta,chnl);
                        end
                    end
                end
            end
            Coeff_matr(index_matr(i,j),index_matr(i,j)) = 4;
        end
    end
end

final_img = double(border_img);
solns = Coeff_matr\B;
for channel = 1:3
    for k = 1:num_pixels
        final_img(I(k),J(k),channel) = solns(k,channel);
    end
end
final_img = uint8(final_img);
figure,imshow(final_img);