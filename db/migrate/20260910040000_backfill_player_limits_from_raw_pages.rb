class BackfillPlayerLimitsFromRawPages < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Backfilling max players from raw page text" do
      Variant.reset_column_information
      Variant.where(max_players: [nil, ""]).find_each do |variant|
        text = variant.source_detail.fetch("raw_pages", []).filter_map { |page| page["Raw Page Text"] }.join(" ")
        match = text.match(/(\d+)\s+Players?\s+Max/i)
        variant.update_columns(max_players: match[1]) if match
      end
    end
  end

  def down
    # Inferred values remain available if this migration is rolled back.
  end
end
