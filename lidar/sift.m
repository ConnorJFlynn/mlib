function [PileA, PileB, v] = sift(range, InMat, YY);
%function [pileA pileB, v] = sift(range, InMat, YY);
%This function was written to cycle through a matrix of MPL overlap profiles, plotting each 
%profile and permitting separation on a case by case basis, generating a subset matrix.
%if no range is supplied, the length of the matrix is taken as the range.
% 2003-08-21 Initially this was called "exclude" and permitted case by case exclusion
% of profiles.  Now it is more generic, separating into two piles.
% YY is a matrix indicating the orientation of the panes
% E.g., YY=[1,2] has two graphs aranged in a single row
% 2004-03-18 added return of the axis vector "v" which defines the plot axis. 

show2 = 0;
XX = [1,1];
if nargin == 1
    InMat = range;
    [bins,profs] = size(InMat);
    range = [1:bins];
elseif nargin == 2
    [bins,profs] = size(InMat);
else
    [bins,profs] = size(InMat);
    if ((YY == [1,2])|(YY==[2,1]))
        show2 = 1;
        XX = YY;
    end
end;

pile = ones(profs,1);
index = 1;
indexA = 1;
indexB = 0;
frame = pile(index);
step = 1;
done = 0;
PileA = find(pile>0);
PileB = find(pile<0);
figure; 
semilogy(range, InMat(:,[PileA]),'y', range,InMat(:,PileA(indexA)),'r', range, mean(InMat(:,PileA)')','g');
title('Zoom in as desired, hit any key to continue')
zoom on;
pause;
v = axis;
lower_limit = max(find(range<=v(1)));
if isempty(lower_limit)
   lower_limit = 1;
end
upper_limit = min(find(range>=v(2)));
if isempty(upper_limit)
   upper_limit = length(range);
end;


while ~done,
    PileA = find(pile>0);
    PileB = find(pile<0);
    if (indexA>length(PileA))
        indexA=1;
    elseif (indexA<1)
        indexA=length(PileA);
    end;
    if (indexB>length(PileB))
        indexB=1;
    elseif (indexB<1)
        indexB=length(PileB);
    end;
    if ((frame==1)&any(PileA))
        index = PileA(indexA);
    elseif ((frame==-1)&any(PileB))
        index = PileB(indexB);
    end
    
    if show2
        subplot(XX(1),XX(2),1,'replace');
        if any(PileA)
            if pile(index)>0
                TitleString = ['Pile A: Profile #', num2str(indexA), ' of ' ,num2str(length(PileA)) '.'];
                semilogy(range, InMat(:,[PileA]),'y', range,InMat(:,PileA(indexA)),'r', range, mean(InMat(:,PileA)')','g');
            else
                TitleString = ['Pile A: Average of ' ,num2str(length(PileA)) ' profiles.'];
                semilogy(range, InMat(:,[PileA]),'y',range, mean(InMat(:,PileA)')','g');
            end
            title(TitleString);
        else 
            TitleString = ['Pile A: empty'];
            title(TitleString);
        end
        axis(v);
        subplot(XX(1),XX(2),max(XX),'replace');
        if any(PileB)
            if pile(index)<0
                TitleString = ['Pile B: Profile #', num2str(indexB), ' of ' ,num2str(length(PileB)) '.'];
                semilogy(range, InMat(:,[PileB]),'y', range,InMat(:,PileB(indexB)),'r', range, mean(InMat(:,PileB)')','g');
            else
                TitleString = ['Pile B: Average of ' ,num2str(length(PileB)) ' profiles.'];
                semilogy(range, InMat(:,[PileB]),'y',range, mean(InMat(:,PileB)')','g');
            end
            title(TitleString);
        else 
            TitleString = ['Pile B: empty'];
            title(TitleString);
        end
        axis(v);
    else %show only one frame
        if pile(index)>0
            if any(PileA)
                TitleString = ['Pile A: Profile #', num2str(indexA), ' of ' ,num2str(length(PileA)) '.'];
                semilogy(range, InMat(:,[PileA]),'y', range,InMat(:,PileA(indexA)),'r', range, mean(InMat(:,PileA)')','g');
            else
                TitleString = ['Pile A: empty'];
            end
        elseif pile(index)<0
            if any(PileB)
                TitleString = ['Pile B: Profile #', num2str(indexB), ' of ' ,num2str(length(PileB)) '.'];
                semilogy(range, InMat(:,[PileB]),'y', range,InMat(:,PileB(indexB)),'r', range, mean(InMat(:,PileB)')','g');
            else
                TitleString = ['Pile B: empty'];
            end;
        end;
        axis(v);
    end;
    title(TitleString);
    axis(v);
    
    keep = input('Move profile into other pile, Switch frames, Reverse direction, or eXit? {M,S,R,X,<CR>}', 's');
    if isempty(keep)
        keep = ' ';
    end;
    if (upper(keep) == 'S') % switch frames
        frame = frame * -1;
    elseif (upper(keep) == 'R') % reverse direction
        step = step * -1;
        if ((frame==1)&(any(PileA)))
            indexA = indexA + step;
        elseif ((frame==-1)&(any(PileB)))
            indexB = indexB + step;
        end;        
    elseif (upper(keep)=='X')
        done = 1;
    elseif (upper(keep)=='M') % move current profile to other group
        pile(index) = pile(index) * -1;
        %commented on 2003-08-24 to fix an index problem of skipping profiles when moving
%         if ((frame==1)&(any(PileA)))
%             indexA = indexA + step;
%         elseif ((frame==-1)&(any(PileB)))
%             indexB = indexB + step;
%         end;
    else 
        if ((frame==1)&(any(PileA)))
            indexA = indexA + step;
        elseif ((frame==-1)&(any(PileB)))
            indexB = indexB + step;
        end;
    end;
end;

if show2
    subplot(XX(1),XX(2),1,'replace');    
    if any(PileA)
        TitleString = ['Pile A: Average of ' ,num2str(length(PileA)) ' profiles.'];
        semilogy(range, mean(InMat(:,PileA)')','g');
    else
        TitleString = ['Pile A: empty'];
    end;
    title(TitleString);
    axis(v);
    subplot(XX(1),XX(2),max(XX),'replace');
    if any(PileB) 
        TitleString = ['Pile B: Average of ' ,num2str(length(PileB)) 'profiles.'];
        semilogy(range, mean(InMat(:,PileB)')','g');
    else
        TitleString = ['Pile B: empty'];
    end
    title(TitleString);
    axis(v);
else
    if pile(index)>0
        if any(PileA)
            TitleString = ['Pile A: Average of ' ,num2str(length(PileA)) ' profiles.'];
            semilogy(range, mean(InMat(:,PileA)')','g');
        else
            TitleString = ['Pile A: empty'];
        end
    elseif pile(index)<0
        if any(PileB)
            TitleString = ['Pile B: Average of ' ,num2str(length(PileB)) ' profiles.'];
            semilogy(range, mean(InMat(:,PileB)')','g');
        else
            TitleString = ['Pile B: empty'];
        end;
    end;
    title(TitleString);   
    axis(v);
end;