class RailsPowergrid::Column
  default_for :visible, true
  add_to_hash do
    { visible: visible? }
  end

  def visible?
    @opts[:visible]
  end

  def visible= x
    @opts[:visible] = x
  end
end