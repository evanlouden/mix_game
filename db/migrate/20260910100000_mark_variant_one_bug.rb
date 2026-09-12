class MarkVariantOneBug < ActiveRecord::Migration[8.1]
  def up
    variant = Variant.find_by(source_id: "V001") || Variant.order(:id).first
    variant&.update_columns(bug: true)
  end

  def down
    variant = Variant.find_by(source_id: "V001") || Variant.order(:id).first
    variant&.update_columns(bug: false)
  end
end
