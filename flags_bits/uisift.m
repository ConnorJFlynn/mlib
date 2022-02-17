function [A,B] = uisift(x,y)
%[a,b] = uisift(x,y)
% Provided with x,y data series (or x as Mx2 or 2xN) will interactively
% allow user to select points to "include" or "exclude" from a graphical
% display.
% Returns logicals A and B, A to include, B to exclude

if isavar('x')

    if isavar('x')&&~isavar('y')
        [m,n] = size(x);
        if m==1&&n>1 || m>1&&n==1
            y = x; x = [1:length(x)];
        elseif m==2&&n>1
            y = x(2,:);
            x = x(1,:);
        elseif m>1&&n==2
            y = x(:,2);
            x = x(:,1);
        end
    end
    if ~all(size(x)==size(y))
        warning('x and y must be of equal size');
        A = []; B = [];
    else
        done = false;
        ax_md = 1; % lin XY
        md = 3; mod_str = 'toggle';
        figure; plot(x,y); v = axis;  g_ = x>=v(1)&x<=v(2)&y>=v(3)&y<=v(4);
        g = nan(size(g_)); g(g_) = 0; b = zeros(size(g_)); b(g_) = NaN;
        plot(x,g+y,'-o',x, b+y, '-rx'); legend('include','exclude'); zoom('on');
        
        while ~done
            mn = menu(['Zoom and select to ',mod_str,' data values:'],'within','outside', 'above','below','left','right',['mode: [',mod_str,']'],'axes', 'DONE');
             v = axis; v_ = g_;
            if mn ==1
                v_ = x>=v(1)&x<=v(2)&y>=v(3)&y<=v(4);
            elseif mn == 2
                v_ = x<v(1)|x>v(2)|y<v(3)|y>v(4);
            elseif mn==3
                v_ = y>v(4);
            elseif mn==4
                v_ = y<v(3)
            elseif mn==5
                v_ = x<v(1);
            elseif mn==6
                v_ = x>v(2);
            elseif mn ==7
                lst_md = md;
                md = menu('Select:','Include','Exclude','Toggle','Inverse','RESET ALL')
                if md==1
                    mod_str = 'include';
                elseif  md==2
                    mod_str = 'exclude';
                elseif md==3
                    mod_str = 'togggle';
                elseif md==4
                    g_ = ~g_;
                elseif md==5
                    g_(~g_) = true;
                end
            elseif mn==8
                ax_md = menu('Set axis mode:','lin XY','semilogx','semilogy','loglog','skip');

            elseif mn==9
                done = true;
            end
            if mn<7
            if md==1
                g_(v_) = true;
            elseif md==2
                g_(v_) = false;
            elseif md==3
                g_(v_) = ~g_(v_);
            end
            end
           
            g = nan(size(g_)); g(g_) = 0; b = zeros(size(g_)); b(g_) = NaN;
            plot(x,g+y,'-o',x, b+y, '-rx'); legend('include','exclude'); zoom('on')
            
            if ax_md==1
                linx;liny;
            elseif ax_md==2
                logx;liny;
            elseif ax_md==3
                linx;logy;
            elseif ax_md==4
                logy;logx;
            end

        end
    end
    A = g_; B= ~g_;
else
    warning('x is required');
    A = []; B = [];
end
