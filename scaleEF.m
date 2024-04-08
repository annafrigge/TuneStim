function EF = scaleEF(VEFStjude,alpha)
        EFinitial=VEFStjude;
        EF(:,1:3) = EFinitial(:,1:3);
        EF(:,5:7) = alpha*EFinitial(:,5:7);
        EF(:,8) = sqrt(sum(EF(:,5:7).^2,2));
end