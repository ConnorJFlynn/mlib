function test_internal

tmp0 = isafile(which('test_internal'));

tmp1 = isavar('tmp');

tmp2 = isavar('tmp1');

%nested function isavar
    function TF = isavar(var)
        TF = false;
        if ~isempty(who('var'))
            TF = ~isempty(who(var));
        end
    end

end