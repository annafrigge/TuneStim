function [Vpoint,Epoint,Epointnorm] = MFS(EFnear,rownames,point,noise,tol)
% see Cubo_2015_Electric_field_modeling_and_spatial_control
% Singular value truncation method used as regularization scheme
% fieldnames returns the fieldnames of a structure e.g. x for E.x
% EFnear contains the electric field
    
    EFnearpos=EFnear{1}(:,1:3);
    
    %cubec=mean(EFnearpos); % centre of grid
    %spoints=spheregen(cubec,0.01,8,8,8);
    
    c = bsxfun(@minus,EFnearpos,point);
    
    n=8;
    dist = 8*norm(c(:,end));
    spoints=spheregen(point,dist,n,n,n); % compute 24 singularity points to 
                                         % estimate electric field
    
    
    r=zeros(length(EFnearpos),length(spoints));
    % coordinates i.e. columns 1-3
    for i=1:length(EFnearpos)
        for j=1:length(spoints)
            r(i,j)=1/norm(EFnearpos(i,:)-spoints(j,:));
        end
    end
    
    % estimate of electric potential
    for l=1:length(rownames)
            for k=1:length(EFnearpos)
                V.(rownames{l})(k,1)=EFnear{l}(k,4) + (EFnear{l}(k,4)*noise*randn());
            end
    end


% singular value truncation method to estimate

    [Ur,Sr,Vr]=svd(r); %singular value decomposition of matrix r
    Srmax=max(diag(Sr)); %get the maxmimum valuee on the diagonal of Sr
    nt=length(spoints);

    for k=2:length(spoints)
        
        if Srmax > tol*Sr(k,k)
            nt=k-1; %if a certain tolerance is reached, break there. The singular values appear in descending order.
            break
        end
    end

    Wr=zeros(length(spoints));
    
    for k=1:nt
        Wr(k,k)=1/Sr(k,k);
    end

    rinv=Vr*Wr*Ur';
   
    

    for l=1:length(rownames)
            lambda.(rownames{l}) = rinv*V.(rownames{l});  %compute lambda for each contact and position?   
    end

    
    for l=1:length(rownames)
            Vpoint.(rownames{l}) = 0;
            Epointx.(rownames{l}) = 0;
            Epointy.(rownames{l}) = 0;
            Epointz.(rownames{l}) = 0;      
    end


    
    for k=1:length(spoints)
        if iscell(point)==1
                point=point{1}(1,1:3);
        end
        rpoint =  norm(point-spoints(k,:));
        
        for l=1:length(rownames)  
            
            % estimate Voltage V
            Vpoint.(rownames{l}) = Vpoint.(rownames{l}) + lambda.(rownames{l})(k)*rpoint^-1; %ur = sum(lambda*G(r,r')
            
            %estimate E-field
            Epointx.(rownames{l}) = Epointx.(rownames{l}) + (lambda.(rownames{l})(k) * ((point(1) - spoints(k,1)) * rpoint^(-3)));
            Epointy.(rownames{l}) = Epointy.(rownames{l}) + (lambda.(rownames{l})(k) * ((point(2) - spoints(k,2)) * rpoint^(-3)));
            Epointz.(rownames{l}) = Epointz.(rownames{l}) + (lambda.(rownames{l})(k) * ((point(3) - spoints(k,3)) * rpoint^(-3)));   
            
            
        end
    end

    %estimate norm
    for l = 1:length(rownames)
        Epoint.(rownames{l}) = [Epointx.(rownames{l}) Epointy.(rownames{l}) Epointz.(rownames{l})];
        Epointnorm.(rownames{l}) = norm(Epoint.(rownames{l}));
    end
    

end