class SetOmahaPotLimitOptions < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE variants
      SET pot_limit = TRUE,
          no_limit = FALSE
      WHERE family = 'Omaha'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Omaha betting options were normalized and cannot be restored safely"
  end
end
