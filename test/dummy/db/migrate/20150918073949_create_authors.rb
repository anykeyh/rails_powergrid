class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.string :nationality, index: true

      t.timestamps null: false
    end
  end
end
