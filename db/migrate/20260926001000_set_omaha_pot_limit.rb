class SetOmahaPotLimit < ActiveRecord::Migration[8.1]
  def up
    Variant.where("name ILIKE ?", "%Omaha%").update_all(no_limit: false, pot_limit: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Omaha betting-option corrections cannot be restored safely"
  end
end
