class RemoveCommunityBoardFromVariants < ActiveRecord::Migration[8.1]
  def change
    remove_column :variants, :community_board, :text if column_exists?(:variants, :community_board)
  end
end
