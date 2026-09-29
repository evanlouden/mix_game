class NormalizeBringInValues < ActiveRecord::Migration[8.1]
  def up
    Variant.where("bring_in ILIKE 'High Card Bring-In%'").update_all(bring_in: "high")
    Variant.where("bring_in ILIKE 'Low Card Bring-In%'").update_all(bring_in: "low")
    Variant.where("bring_in ILIKE 'Low Card Bring-in%'").update_all(bring_in: "low")
  end

  def down
    Variant.where(bring_in: "high").update_all(bring_in: "High Card Bring-In")
    Variant.where(bring_in: "low").update_all(bring_in: "Low Card Bring-In")
  end
end
