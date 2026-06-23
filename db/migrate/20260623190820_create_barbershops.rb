class CreateBarbershops < ActiveRecord::Migration[8.1]
  def change
    create_table :barbershops do |t|
      t.string :name
      t.string :phone
      t.string :address

      t.timestamps
    end
  end
end
