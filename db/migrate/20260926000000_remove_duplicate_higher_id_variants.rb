class RemoveDuplicateHigherIdVariants < ActiveRecord::Migration[8.1]
  HIGHER_IDS = [
    154, 155, 157, 156, 87, 88, 95, 172, 89, 150, 151, 142, 201, 205,
    152, 153, 143, 202, 232, 90, 86, 94, 212, 110, 111, 167, 168, 122,
    123, 197, 112, 171, 174, 173, 176, 175, 97, 98, 181, 106, 107, 126,
    127, 198, 128, 129, 219, 148, 149, 221, 120, 227, 193, 141, 196,
    138, 139, 140, 194, 195, 231, 200, 234, 204, 144, 145, 241, 124, 125
  ].freeze

  def up
    Variant.where(id: HIGHER_IDS).find_each(&:destroy!)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Duplicate variants and their associated data cannot be restored safely"
  end
end
