ActionController::Routing::Routes.draw do |map|
  
  map.charge "/charge", :controller=>"payments", :action=>"charge"
  
end
