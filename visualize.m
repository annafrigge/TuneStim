function [fig,ax,lgd] = visualize()
    
    ColorMode = [0.1 0.1 0.1];
    fig = uifigure('Name','VTA visualisation','WindowStyle','modal');
    fig.Color = ColorMode;
    fig.Position =  [100 200 800 600];


    ax = uiaxes(fig,'Position',[-50 0 800 550]);
    ax.Color = ColorMode;
    ax.XColor = ColorMode;
    ax.YColor = ColorMode;
    ax.ZColor = ColorMode;
    
    fac=0.5;
    ax.XLim(1)=ax.XLim(1)-fac*norm(ax.XLim(1)-ax.XLim(2));
    ax.XLim(2)=ax.XLim(2)+fac*norm(ax.XLim(1)-ax.XLim(2));

    %ax.YLim(1)=ax.YLim(1)-fac*norm(ax.YLim(1)-ax.YLim(2));
    %ax.YLim(2)=ax.YLim(2)+fac*norm(ax.YLim(1)-ax.YLim(2));

    
    legend(ax)
    lgd=ax.Legend;
    lgd.Interpreter='none';
    lgd.Position = [0.8 0.4 0.1 0.2];

    lgd.FontSize = 12;
    lgd.FontName = 'Avenir';
    lgd.EdgeColor = 'None';
    lgd.TextColor ='white';
    try
        lgd.ItemHitFcn = @unsee_Callback;
    end
    
    
     


    function unsee_Callback(ax, event)
        if  event.Peer.Visible=='off'
            event.Peer.Visible='on';
        else
            event.Peer.Visible='off';
        end

     
    end
 
    


    
end