class RailsPowergrid::Preference < ActiveRecord::Base
  self.arel_table = "rails_powergrid_preferences"

  validates :grid_name, presence: true
  validates :column_name, presence: true

  belongs_to :owner, polymorphic: true

  def merge kv
    self.value_json = value_json.merge(kv)
  end

  def value_json
    if value
      @value_json ||= JSON.parse(value)
    else
      @value_json ||= {}
    end
  end

  def value_json=x
    @value_json = x
    value = x.to_json
  end

  class << this
    def get_columns(owner, grid)
      where(owner: owner, grid_name: grid.name).all
    end

    def update(owner, grid, column, kv)
      pref = where(owner: owner, grid_name: grid.name, column_name: column).first_or_initialize
      pref.merge(kv)
      pref.save!
    end

    def clear owner, grid=nil, column=nil
      query = where(owner: owner)
      if grid
        query = where(grid_name: grid.name)
      end

      if column
        query = where(column: column)
      end

      # We use delete instead of destroy for performances,
      # since we doesn't have triggers and cascade on deletion.
      # Of course this can change in future, so keep it in mind.
      query.delete_all
    end
  end
end