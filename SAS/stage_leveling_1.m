% Stage level tests, 500 Hz, continuous motion:
in_dir = ['C:\case_studies\ARRA\SAS\data_tests\Stage Leveling\test_level_500Hz_continuous\'];

first = loadit([in_dir]);
figure; plot(first(:,[4,5]),'.');legend('X','Y')

clear first_IQ
first_IQ.x2D =downIQ(first(:,4),100); 
first_IQ.y2D =downIQ(first(:,5),100); 

hold('on'); plot([1:100:100.*length(first_IQ.x2D)],[first_IQ.x2D,first_IQ.y2D],'k-');legend('X','Y')
%%