class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name
      t.boolean :active
      t.references :barbershop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
