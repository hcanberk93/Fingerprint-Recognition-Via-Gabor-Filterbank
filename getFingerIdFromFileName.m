function [fingerId] = getFingerIdFromFileName(fileName)
    fingerId = strsplit(fileName,'.');
    fingerId = fingerId{1};
    fingerId = fingerId(1:end-1);
end