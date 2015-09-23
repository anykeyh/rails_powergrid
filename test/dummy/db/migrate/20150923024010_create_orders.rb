class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :status, default: "CART"
      t.datetime :ordered_at, index: true
      t.decimal :total, index: true

      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
