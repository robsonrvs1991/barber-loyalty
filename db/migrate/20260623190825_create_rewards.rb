class CreateRewards < ActiveRecord::Migration[8.1]
  def change
    create_table :rewards do |t|
      t.bigint :customer_id, null: false
      t.references :barbershop, null: false, foreign_key: true
      t.string :description
      t.boolean :used, default: false, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :rewards, :customer_id
    add_foreign_key :rewards, :users, column: :customer_id
  end
end
