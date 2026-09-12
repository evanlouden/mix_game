class AddBettingFormatToVariants < ActiveRecord::Migration[8.1]
  def up
    add_column :variants, :betting_format, :string
    Variant.reset_column_information
    Variant.find_each do |variant|
      format = if variant.betting_structure.to_s.match?(/Fixed-Limit/i) || variant.game_type.to_s.match?(/Fixed-Limit/i)
        "fixed_limt"
      elsif variant.betting_structure.to_s.match?(/Pot-Limit/i)
        "pot_limit"
      else
        "no_limit"
      end
      variant.update_columns(betting_format: format)
    end
  end

  def down
    remove_column :variants, :betting_format
  end
end
