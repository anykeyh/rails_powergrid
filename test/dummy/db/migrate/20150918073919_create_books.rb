class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name, index: true
      t.references :author, index: true
      t.text :summary
      t.string :isbn_number, index: true
      t.datetime :published_at, index: true

      t.timestamps null: false
    end
  end
end
