function [] = classify()
    if ~isfolder('Train') %Original Train
        mkdir Train
    end

    if ~isfolder('Test') %Original Test
        mkdir Test
    end

    if ~isfolder('BTrain') %Binary Train
        mkdir BTrain
    end

    if ~isfolder('BTest') %Binary Test
        mkdir BTest
    end

    for k=1:50
        filePath = strcat('FingerprintDB/sub',int2str(k));
        fileList = dir(filePath);
        for j=1:length(fileList)
            if strcmp(fileList(j).name,'.') || strcmp(fileList(j).name,'..')
                continue
            end
            fileName =strsplit(fileList(j).name,'.');
            fileName =fileName{1};
            newFilePath = strcat(filePath,'/',fileList(j).name);
            if (fileName(end) =='5')
                copyfile(newFilePath,'Test')
            else
                copyfile(newFilePath,'Train')
            end
        end
    end
end



