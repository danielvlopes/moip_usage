ActionController::Routing::Routes.draw do |map|
  map.manual_charge "/manual_charge", :controller=>"payments", :action=>"manual_charge"
  map.direct_charge "/direct_charge", :controller=>"payments", :action=>"direct_charge"
  map.payment_return "/payment_return", :controller=>"payments", :action=>"payment_return"  
end
