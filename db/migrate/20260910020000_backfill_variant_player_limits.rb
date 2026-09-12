class BackfillVariantPlayerLimits < ActiveRecord::Migration[8.1]
  def up
    say_with_time "Backfilling max players from special mechanics" do
      execute <<~SQL
        UPDATE variants
        SET max_players = substring(special_mechanics from '(\\d+)\\s+Players?\\s+Max')
        WHERE (max_players IS NULL OR btrim(max_players) = '')
          AND special_mechanics ~* '\\d+\\s+Players?\\s+Max'
      SQL
    end
  end

  def down
    # Inferred values remain available if this migration is rolled back.
  end
end
