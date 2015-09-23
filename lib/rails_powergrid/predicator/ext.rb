class ActiveRecord::Base
  def self.predicator parameter, grid, opts={}
    opts = Predicator::DEFAULT_OPTS.merge(opts)
    Predicator::create_predicate(self.where(nil), parameter, grid, opts)
  end
end