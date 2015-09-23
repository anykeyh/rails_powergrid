class CreateOrderLines < ActiveRecord::Migration
  def change
    create_table :order_lines do |t|
      t.references :book, index: true, foreign_key: true
      t.integer :quantity
      t.decimal :total

      t.timestamps null: false
    end

    add_column :books, :price, :decimal
  end
end
