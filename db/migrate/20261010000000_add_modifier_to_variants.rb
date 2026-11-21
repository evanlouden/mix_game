class AddModifierToVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :variants, :modifier, :string
  end
end
