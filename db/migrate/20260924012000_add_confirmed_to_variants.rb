class AddConfirmedToVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :variants, :confirmed, :boolean, default: false, null: false
  end
end
