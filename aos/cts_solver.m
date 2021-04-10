function [delta_a_, status] = cts_solver(delta_f_meas, delta_s_meas, g_meas, delta_a_start);

%  Constrained Two Stream Solver
%  solve for delta_a
%  Method: Newton approximation
%  delta_f_meas :  calculated from transmittance or integration of sigma_f
%  delta_s_meas :  calculated using nephelometer total scattering,  flow rate and spot size of PSAP
%  g_meas	   :  calculated using nephelometer total and back scattering ( g is function a of BS/TS)
%  delta_a_start:  is delta_a_start the value of the absorption optical depth calculated before, this algorithm converges very fast 
    fd_stop = 1e-7;
    maxiter=10;  %maximum number of iterations
    k=0.0001;    %used for calculating the 1st derivative 
    delta_f_meas(delta_f_meas < 0)=0;
    delta_s_meas(delta_s_meas < 0.0) = 0.0;
    g_meas(g_meas < 0.0) =0;
    g_meas(g_meas > 1.0)= 1.0;
    
    delta_a_start(delta_a_start < 0.0) = 0.0 ;
    delta_a(1) = delta_a_start;
    %     delta_a(end+1) = delta_a_start;
    i = 1; done = false;
    while i<maxiter && ~done
        result_delta_f=delta_f(delta_a(end), delta_s_meas, g_meas);
        result_delta_f_plus_k = delta_f(delta_a(end)+k, delta_s_meas, g_meas);
        first_derivative=(result_delta_f_plus_k-result_delta_f)./k;
        modification = (result_delta_f - delta_f_meas)./first_derivative;
        ada = delta_a(end)-modification;
        delta_a(end+1)=ada;
        if (i == 1);
            lda = delta_a(end-1);
            if (abs(lda) > abs(ada))
                ma=abs(lda);
            else
                ma = abs(ada);
            end
            if (ma == 0) || (abs(lda - ada) ./ ma < fd_stop)
                done = true;
            end
        end
        % I don't know what the push and pop commands do
        % 	return (pop @delta_a, 1);
    end

delta_a_ = delta_a(end); status = 1;
return