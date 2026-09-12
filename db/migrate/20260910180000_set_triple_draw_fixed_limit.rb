class SetTripleDrawFixedLimit < ActiveRecord::Migration[8.1]
  def up
    Variant.where("name ILIKE '%Triple Draw%'").update_all(game_type: "Fixed-Limit")
  end

  def down
    # Triple-draw variants are intentionally fixed-limit.
  end
end
