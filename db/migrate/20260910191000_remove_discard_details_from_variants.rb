class RemoveDiscardDetailsFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :discard_details, :text if column_exists?(:variants, :discard_details)
  end
end
