require 'json'

class String
  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end
end
