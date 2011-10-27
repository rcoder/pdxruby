ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  map.home '/', :controller => "index", :action => "index"

  map.login '/login', :controller => "members", :action => "login"
  map.logout '/logout', :controller => "members", :action => "logout"
  map.reset '/reset', :controller => "members", :action => "reset"

  map.connect '', :controller => "index", :action => "index"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

  map.connect '/pdx.rb.ics', :controller => 'events', :action => 'ical'
end
