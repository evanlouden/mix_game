class RemoveLegacySequenceStepFields < ActiveRecord::Migration[8.1]
  def change
    remove_column :sequence_steps, :metadata, :jsonb
    remove_column :sequence_steps, :details, :text
    remove_column :sequence_steps, :source_pages, :string
    remove_column :sequence_steps, :label, :string
  end
end
