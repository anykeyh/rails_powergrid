###
# Mixin for HTML passed data (used for custom stuff like custom renderer etc...)
###
class RailsPowergrid::Column
  default_for :html, {}

  add_to_hash do
    { type: html }
  end

  def html
    @opts[:html]
  end

  def html=x
    @opts[:html]
  end
end