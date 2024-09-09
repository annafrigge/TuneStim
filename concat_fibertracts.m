function AllTracts = concat_fibertracts(region,space,tract_names,hand)
%side 1 = lh, 2 = rh
    if strcmp(hand,'sin')
        side = 1;
    elseif strcmp(hand,'dx')
        side = 2;
    end

idxTracts = contains({region.(space).name{:,side}},tract_names)';

TractCoords = region.(space).coords(idxTracts,side);
m = 0;
for i=1:sum(idxTracts)
    AllTracts = [TractCoords{i}(:,1:3) TractCoords{i}(:,4)+m];
    m = max(AllTracts(:,4));
end

end