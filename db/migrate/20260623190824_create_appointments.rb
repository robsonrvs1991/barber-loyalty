class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.bigint :customer_id, null: false
      t.bigint :barber_id, null: false
      t.references :service, null: false, foreign_key: true
      t.references :barbershop, null: false, foreign_key: true
      t.boolean :paid, default: true, null: false

      t.timestamps
    end

    add_index :appointments, :customer_id
    add_index :appointments, :barber_id
    add_foreign_key :appointments, :users, column: :customer_id
    add_foreign_key :appointments, :users, column: :barber_id
  end
end
