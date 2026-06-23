class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :role
      t.references :barbershop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
