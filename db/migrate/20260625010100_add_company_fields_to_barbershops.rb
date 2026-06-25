class AddCompanyFieldsToBarbershops < ActiveRecord::Migration[8.1]
  def change
    add_column :barbershops, :legal_name, :string unless column_exists?(:barbershops, :legal_name)
    add_column :barbershops, :document, :string unless column_exists?(:barbershops, :document)
    add_column :barbershops, :email, :string unless column_exists?(:barbershops, :email)
    add_column :barbershops, :whatsapp, :string unless column_exists?(:barbershops, :whatsapp)
    add_column :barbershops, :active, :boolean, default: true, null: false unless column_exists?(:barbershops, :active)
  end
end
