function [] = convertGreyscale()
    testFiles = dir('Test');
    trainFiles = dir('Train');
    
    for i=1:length(testFiles)
        if strcmp(testFiles(i).name,'.') || strcmp(testFiles(i).name,'..')
                continue
        end
        path = strcat(testFiles(i).folder,'/',testFiles(i).name);
        img = imread(path);
        bimg = rgb2gray(img);
        imwrite(bimg, strcat('BTest/',testFiles(i).name));
        
    end
    
    for i=1:length(trainFiles)
        if strcmp(trainFiles(i).name,'.') || strcmp(trainFiles(i).name,'..')
                continue
        end
        path = strcat(trainFiles(i).folder,'/',trainFiles(i).name);
        img = imread(path);
        bimg = rgb2gray(img);
        imwrite(bimg, strcat('BTrain/',trainFiles(i).name));
        
    end
end