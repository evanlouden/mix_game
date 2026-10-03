class SetMissingMaxPlayersToNine < ActiveRecord::Migration[8.0]
  def up
    Variant.where(max_players: [nil, ""]).update_all(max_players: "9")
  end

  def down
    # The previous values were unknown, so there is no safe rollback value.
  end
end
