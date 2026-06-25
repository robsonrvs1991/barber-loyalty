class MakeUserBarbershopOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :barbershop_id, true
  end
end