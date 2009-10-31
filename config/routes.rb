ActionController::Routing::Routes.draw do |map|

  map.charge "/manual_charge", :controller=>"payments", :action=>"manual_charge"
  map.charge "/direct_charge", :controller=>"payments", :action=>"direct_charge"

end
