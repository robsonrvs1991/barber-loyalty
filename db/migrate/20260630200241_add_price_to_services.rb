class AddPriceToServices < ActiveRecord::Migration[8.1]
  def change
    add_column :services,
               :price,
               :decimal,
               precision: 10,
               scale: 2,
               default: 0,
               null: false
  end
end