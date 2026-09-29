class AddBombPotToVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :variants, :bomb_pot, :boolean, default: false, null: false
  end
end
