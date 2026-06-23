class AddAuthAndPointsToV1 < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string unless column_exists?(:users, :password_digest)
    add_index :users, :email, unique: true unless index_exists?(:users, :email)

    add_column :services, :points, :integer, default: 1, null: false unless column_exists?(:services, :points)
    change_column_default :services, :active, from: nil, to: true

    add_column :appointments, :points, :integer, default: 1, null: false unless column_exists?(:appointments, :points)
    add_column :appointments, :notes, :text unless column_exists?(:appointments, :notes)

    add_column :rewards, :earned_at, :datetime unless column_exists?(:rewards, :earned_at)
  end
end
