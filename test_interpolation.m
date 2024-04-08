function  test_interpolation(EF_nearest,test_point,contact_names,method)
    
    %get a random test point
    r_idx = randperm(length(test_point),1);
    test_sample = test_point{r_idx}; 
    EF_nearest_sample = EF_nearest{r_idx};

    for j=1:length(contact_names)
        [~,~,EFnorm_test] = EV_point(EF_nearest_sample ,contact_names,test_sample{j}(1:3),0,1e8,method);  
        err=100*(EFnorm_test.(contact_names{j})-test_sample{j}(8))/test_sample{j}(8);
        if (norm(err)>10)
            disp(norm(err))
            warning('The interpolation error is higher than 10%.')
        end
    end
end