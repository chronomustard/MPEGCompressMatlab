clear;

image = imread('coastguard003.tiff');
[frameY, frameCr, frameCb] = ccir2ycrcb(image);
mBYprev=uint8(frameY(1:16,1:16));

refImage = imread('coastguard001.tiff');
[refFrameY, refFrameCr, refFrameCb] = ccir2ycrcb(refImage);
mBIndex=0;
[eMBY, eMBCr, eMBCb, mV] = motEstP(frameY, frameCr, frameCb, mBIndex, refFrameY, refFrameCr, refFrameCb);
[mBY, mBCr, mBCb] = iMotEstP(eMBY, eMBCr, eMBCb, mBIndex, mV, refFrameY, refFrameCr, refFrameCb);

mBYprev=single(frameY(1:16,1:16));
predError=mBYprev-mBY;
imwrite(predError, 'predError.png');

bName = 'coastguard';
fExtension = '.tiff';
startFrame = 0;
numOfGoPs =4;
qScale =8;
SeqEntity=encodeMPEG(bName, fExtension, startFrame, numOfGoPs, qScale);

save('seq','SeqEntity')

size = getSeqEntityBits(SeqEntity);
fprintf('Size of encoded file: %d Bytes\n',size/8);

outFName = 'decoded_coastguard';
fName = 'seq';
decodeMPEG(fName, outFName);

% compute mean errors
meanErrors=[];
meaner=[];
for i=0:11 
    orig = sprintf('%s%03d%s',bName,i,'.tiff');
    dec = sprintf('%s%03d%s',outFName,i,'.tiff');
    
    if exist(dec,'file')==2
        originalFrame = imread(orig);
        decFrame = imread(dec);
        
        error = abs(originalFrame-decFrame);
        meanErrors=[meanErrors;i mean2(error)];
    end
end
% the first column is the number of the image
% and the second is the value of the mean error
meanErrors


