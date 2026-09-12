class RemoveBugFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :bug, :boolean if column_exists?(:variants, :bug)
  end
end
