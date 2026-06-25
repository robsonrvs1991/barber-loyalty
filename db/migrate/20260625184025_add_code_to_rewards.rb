class AddCodeToRewards < ActiveRecord::Migration[8.1]
  def change
    add_column :rewards, :code, :string
    add_index :rewards, :code, unique: true
  end
end