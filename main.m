%% Example of Log Gabor Image
exImg = imread('BTest/15.jpg');
wavelength = 5;
orientation = 8;
[mag,phase] = imgaborfilt(exImg,wavelength,orientation);
%result_image = log_gabor_filter(imgTest, 4, 6, 3, 1.7, 0.65, 1.3)
figure
subplot(1,3,1);
imshow(exImg);
title('Original Image');
subplot(1,3,2);
imshow(mag,[])
title('Gabor Magnitude');
subplot(1,3,3);
imshow(phase,[]);
title('Gabor Phase');

%% Fundamental Classify Functions
classify();
convertGreyscale();
%% Test a Sample
imgTest = imread('BTest/25.jpg');
imgTest = imresize(imgTest,[100,100]);
gaborArray = gaborFilterBank(5,8,39,39);
g1 = gaborFeatures(imgTest,gaborArray,4,4);

trainFiles = dir('BTrain/*.jpg');
distanceVal = zeros(numel(trainFiles),1);
distanceValNorm = zeros(numel(trainFiles),1);
for i = 1:numel(trainFiles)
    img = imread(strcat(trainFiles(i).folder,'/',trainFiles(i).name));
    img = imresize(img,[100,100]);
    gaborArray = gaborFilterBank(5,8,39,39);
    g2 = gaborFeatures(img,gaborArray,4,4);

    E_distance = mean(mean(sqrt(sum((g2-g1).^2))));
    ENorm_distance = immse(imgTest,img); 

    distanceVal(i) = E_distance;
    distanceValNorm(i) = ENorm_distance;
end
index = find(distanceVal == min(distanceVal));
disp(index);
disp(trainFiles(index).name);
index = find(distanceValNorm == min(distanceValNorm));
disp(index);
disp(trainFiles(index).name);
matchId = strsplit(trainFiles(index).name,'.');
matchId = matchId{1};
matchId = matchId(1:end-1);

%%
testFiles = dir('BTest/*.jpg');
resultGabor = zeros(numel(testFiles),1);
resultGaborNorm = zeros(numel(testFiles),1);
for k=1:numel(testFiles)
    fingerId = getFingerIdFromFileName(testFiles(k).name);
    
    path = strcat(testFiles(k).folder,'/',testFiles(k).name);
    imgTest = imread(path);
    imgTest = imresize(imgTest,[100,100]);
    gaborArray = gaborFilterBank(5,8,39,39);
    g1 = gaborFeatures(imgTest,gaborArray,4,4);

    trainFiles = dir('BTrain/*.jpg');
    distanceVal = zeros(numel(trainFiles),1);
    distanceValNorm = zeros(numel(trainFiles),1);
    
    for i = 1:numel(trainFiles)
        img = imread(strcat(trainFiles(i).folder,'/',trainFiles(i).name));
        img = imresize(img,[100,100]);
        gaborArray = gaborFilterBank(5,8,39,39);
        g2 = gaborFeatures(img,gaborArray,4,4);

        E_distance = mean(mean(sqrt(sum((g2-g1).^2))));
        ENorm_distance = immse(imgTest,img); 
        
        distanceVal(i) = E_distance;
        distanceValNorm(i) = ENorm_distance;
    end
    index = find(distanceVal == min(distanceVal));
    matchId = getFingerIdFromFileName(trainFiles(index).name);
    resultGabor(k) = strcmp(fingerId,matchId);
    
    index = find(distanceValNorm == min(distanceValNorm));
    matchId = getFingerIdFromFileName(trainFiles(index).name);
    resultGaborNorm(k) = strcmp(fingerId,matchId);
end
successGabor = mean(resultGabor)*100;
successGaborLog = mean(resultGaborNorm)*100;
disp(successGabor);
disp(successGaborLog);

%%
f = waitbar(0,'Please wait...');
pause(.5)

waitbar(.33,f,'Loading your data');
pause(1)

waitbar(.67,f,'Processing your data');
pause(1)

waitbar(1,f,'Finishing');
pause(1)

close(f)
%%
function [fingerId] = getFingerIdFromFileName(fileName)
    fingerId = strsplit(fileName,'.');
    fingerId = fingerId{1};
    fingerId = fingerId(1:end-1);
end
%%