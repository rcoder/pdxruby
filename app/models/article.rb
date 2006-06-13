class Article < ActiveRecord::Base
  belongs_to :member

  def filtered_content
    unless content.to_s.empty?
      content.gsub(/<(script|img|object|iframe).*?\/(>|\1>)/, '[\1]')
    end
  end
end
