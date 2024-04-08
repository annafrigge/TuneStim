function [rpoint,lambda,spoints] = svd_removal(nearest_neighbors,point)
        tol=1e8;

        EFnearpos = nearest_neighbors;
        c  = bsxfun(@minus,EFnearpos,point);
        spoints=spheregen(point,50*norm(c(:,end)),8,8,8);
     
        r=zeros(length(EFnearpos),length(spoints));

        % coordinates i.e. columns 1-3
        for i=1:length(EFnearpos)
            for j=1:length(spoints)
                r(i,j)=1/norm(EFnearpos(i,:)-spoints(j,:));
            end
        end

     
     
        % singular value truncation method to estimate

        [Ur,Sr,Vr]=svd(r); %singular value decomposition of matrix r
        Srmax=max(diag(Sr)); %get the maxmimum valuee on the diagonal of Sr
        nt=length(spoints);

        for l=2:length(spoints)
            
            if Srmax > tol*Sr(l,l)
                nt=l-1; %if a certain tolerance is reached, break there. The singular values appear in descending order.
                break
            end
        end

        Wr=zeros(length(spoints));
        
        for l=1:nt
            Wr(l,l)=1/Sr(l,l);
        end

        rinv=Vr*Wr*Ur';
        
        rpoint=zeros(length(spoints),1);
        for l=1:length(spoints)
            rpoint(l) =  norm(point-spoints(l,:));
        end

        
end