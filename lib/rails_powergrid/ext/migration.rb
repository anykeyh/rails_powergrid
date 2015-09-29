module RailsPowergrid::Migration
  def rails_powergrid_audits!
    create_table :rails_powergrid_audits do |t|
      t.string  :grid_name, index: true

      t.integer :resource_id, index: true, null: false
      t.string  :resource_type, index: true, null: false

      t.integer :owner_type, index: true
      t.string  :source_type, index: true

      t.string :action, index: true, null: false

      t.jsonb :values, default: '{}'
    end

    add_index  :rails_powergrid_audits, :values, using: :gin
  end

  def rails_powergrid_preferences!
    create_table :rails_powergrid_preferences do
      t.string :grid_name, index: true
      t.string :column_name, index: true

      t.jsonb :values, default: '{}'
    end
    add_index  :rails_powergrid_preferences, :values, using: :gin
  end

  def rails_powergrid!
    rails_powergrid_audits!
    rails_powergrid_preferences!
  end
end