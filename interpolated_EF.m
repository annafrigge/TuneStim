function EF_interpolated = interpolated_EF(rinv,r_point,EFnearest,j,nearest_neighbors,s_points,points)
    
    noise=0;
    EF_interpolated = zeros(length(points),8);

   

    for k=1:length(points)
        point=points(k,:);

        nearest = EFnearest{k}{j};
        spoints=s_points{k};
        rpoint=r_point{k};
        
        
      
        EFnearpos=nearest;
        assert(length(EFnearpos)==24)


        % estimate of electric potential
         
        V=zeros(length(EFnearpos),1);
        for l=1:length(EFnearpos)
                    V(l,1)=EFnear(l,4) + (EFnear(l,4)*noise*randn());
        end
        
     
        lambda = rinv{k}*V;

        Vpoint=0;
        Epointx=0;
        Epointy=0;
        Epointz=0;

        for l=1:length(spoints)
            
            Vpoint = Vpoint + lambda(l)*rpoint(l)^-1; 
            
            Epointx = Epointx + (lambda(l) * ((point(1) - spoints(l,1)) * rpoint(l)^(-3)));
            Epointy = Epointy + (lambda(l) * ((point(2) - spoints(l,2)) * rpoint(l)^(-3)));
            Epointz = Epointz + (lambda(l) * ((point(3) - spoints(l,3)) * rpoint(l)^(-3))); 
        end

        Enorm = norm([Epointx, Epointy,Epointz]);
     
        EF_interpolated(k,:) = [point(1),point(2),point(3),Vpoint,Epointx,Epointy,Epointx,Enorm];
 

    end
end