function updatePlotZono(varargin)

%If only two  argument is passed
if nargin==1
    Z=varargin{1};
    dims=[1,2];
    type{1}='b';
    
%If two arguments are passed    
elseif nargin==2
    Z=varargin{1};
    dims=varargin{2};
    type{1}='b';
    
%If three or more arguments are passed
elseif nargin>=3
    Z=varargin{1};
    dims=varargin{2};   
    type(1:length(varargin)-2)=varargin(3:end);
end


% % project zonotope
% Z = project(Z,dims);
% 'Color', varargin{3},'Marker',varargin{4}
% % delete zero generators
% p = polygon(Z);
newh= plot(CZ,dims,'Color',varargin{3},'Template',256);
p1=get(newh,'XData');
p2=get(newh,'YData');
%plot and output the handle
set(h,'XData', p1, 'YData',p2);

%------------- END OF CODE --------------