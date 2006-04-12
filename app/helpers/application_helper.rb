# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

def textilize(what)
   RedCloth.new(what).to_html
end

end
