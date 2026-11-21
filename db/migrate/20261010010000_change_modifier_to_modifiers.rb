class ChangeModifierToModifiers < ActiveRecord::Migration[8.1]
  class VariantRecord < ActiveRecord::Base
    self.table_name = "variants"
  end

  def up
    rename_column :variants, :modifier, :modifiers
    change_column :variants, :modifiers, :text

    VariantRecord.reset_column_information
    VariantRecord.where.not(modifiers: [nil, ""]).find_each do |variant|
      value = variant.modifiers
      next if value.start_with?("[")

      variant.update_columns(modifiers: [value].to_json)
    end
  end

  def down
    VariantRecord.reset_column_information
    VariantRecord.where.not(modifiers: [nil, ""]).find_each do |variant|
      values = JSON.parse(variant.modifiers)
      variant.update_columns(modifiers: values.first)
    end

    rename_column :variants, :modifiers, :modifier
    change_column :variants, :modifier, :string
  end
end
