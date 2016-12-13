clear all;
close all;
%% input and set the percentage
tile_img = imread('images/tile.jpg');
% tile_img = imresize(tile_img,0.5);

%% Top and Bottom

% north_tile = tile_img;
% south_tile = tile_img;
% north_tile(end,:,:) = (north_tile(end,:,:) + south_tile(1,:,:))/2;
% south_tile(1,:,:) = north_tile(end,:,:);
% north_tile = seamless_rect(tile_img,north_tile);
% south_tile = seamless_rect(tile_img,south_tile);
% 
% figure,imshow(cat(1,north_tile,south_tile));
% figure,imshow(cat(1,tile_img,tile_img));

%% Middle

% center_tile = tile_img;
% center_tile(1,:,:) = (tile_img(1,:,:) + tile_img(end,:,:))/2;
% center_tile(end,:,:) = center_tile(1,:,:);
% center_tile(:,1,:) = (tile_img(:,1,:) + tile_img(:,end,:))/2;
% center_tile(:,end,:) = center_tile(:,1,:);
% center_tile = seamless_rect(center_tile,tile_img);
% 
% 
% y = cat(2,tile_img,tile_img);
% figure,imshow(cat(1,y,y));
% 
% x = cat(2,center_tile,center_tile);
% figure,imshow(cat(1,x,x));

%% Left and Right

east_tile = tile_img;
west_tile = tile_img;
east_tile(:,1,:) = (east_tile(:,1,:) + west_tile(:,end,:))/2;
west_tile(:,end,:) = east_tile(:,1,:);
east_tile = seamless_rect(tile_img,east_tile);
west_tile = seamless_rect(tile_img,west_tile);

figure,imshow(cat(2,west_tile,east_tile));
figure,imshow(cat(2,tile_img,tile_img));




