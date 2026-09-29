class ConsolidateExactBettingVariants < ActiveRecord::Migration[8.1]
  PAIRS = [
    [77, 218],  # Mississippi Stud 8
    [76, 217],  # Mississippi Stud
    [69, 199],  # SOHE 3-1-1
    [19, 121]   # Pineapple 8
  ].freeze

  def up
    PAIRS.each do |canonical_id, duplicate_id|
      canonical = Variant.find_by(id: canonical_id)
      duplicate = Variant.find_by(id: duplicate_id)
      next unless canonical && duplicate

      canonical.update_columns(
        no_limit: canonical.no_limit || duplicate.no_limit,
        pot_limit: canonical.pot_limit || duplicate.pot_limit,
        fixed_limit: canonical.fixed_limit || duplicate.fixed_limit
      )
      duplicate.destroy!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Exact betting variant consolidation cannot be reversed safely"
  end
end
