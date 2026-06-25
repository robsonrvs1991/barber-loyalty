class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    return if table_exists?(:subscriptions)

    create_table :subscriptions do |t|
      t.references :barbershop, null: false, foreign_key: true
      t.string :plan, null: false, default: "monthly"
      t.decimal :price, precision: 10, scale: 2, null: false, default: 19.90
      t.string :status, null: false, default: "trial"
      t.boolean :free, null: false, default: false
      t.boolean :blocked, null: false, default: false
      t.datetime :started_at
      t.datetime :expires_at
      t.datetime :trial_until
      t.datetime :last_payment_at

      t.timestamps
    end

    add_index :subscriptions, :status
    add_index :subscriptions, :free
    add_index :subscriptions, :blocked
  end
end
