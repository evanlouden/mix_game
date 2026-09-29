class RemoveConfirmedFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :confirmed, :boolean, default: false, null: false
  end
end
