class AddPotQualifiersToVariants < ActiveRecord::Migration[8.1]
  def change
    add_column :variants, :pot_1_qualifier, :string
    add_column :variants, :pot_2_qualifier, :string
  end
end
