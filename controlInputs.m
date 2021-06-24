function [result] = controlInputs(inputs)
    result = 1;
    for i=1:numel(inputs)
        x = str2num(inputs(i));
        if isempty(x) || mod(x,1)~=0
            result = 0;
            break;
        end
    end
end