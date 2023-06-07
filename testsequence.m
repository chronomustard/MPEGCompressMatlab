clear;

for n=1:11
  images{n} = imread(sprintf('coastguard%03d.tiff',n));
end
for n=1:11
   images{n} = imshow(sprintf('coastguard%03d.tiff',n));
   pause(0.25);
end