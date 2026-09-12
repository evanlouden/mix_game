class RemoveRaiseToOpenFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :raise_to_open, :text if column_exists?(:variants, :raise_to_open)
  end
end
