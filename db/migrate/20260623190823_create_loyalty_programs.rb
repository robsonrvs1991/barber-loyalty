class CreateLoyaltyPrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :loyalty_programs do |t|
      t.integer :required_visits
      t.string :reward_description
      t.references :barbershop, null: false, foreign_key: true

      t.timestamps
    end
  end
end
