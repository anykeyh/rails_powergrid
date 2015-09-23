class Author < ActiveRecord::Base
  has_many :books

  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def to_s
    full_name
  end
end
