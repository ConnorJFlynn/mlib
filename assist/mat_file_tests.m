% Create test mat file for ASSIST JMatIO testing
% 
%
test_mat.char_var = char('hello world');
test_mat.int32_limits = int32([intmin,intmax]);
test_mat.single_var = single([-4,-2,-1,0,1,2,4,0.5, 0.25, 0.125]);
test_mat.single_limits = single([realmin('single'),realmax('single')]);
save('C:\matlib\test_mat.mat','test_mat','-V6');
%%

test_mat2.My_var_name = test_mat;
save('C:\matlib\test_mat2.mat','test_mat2','-V6');