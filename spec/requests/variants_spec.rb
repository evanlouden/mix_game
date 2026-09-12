require "rails_helper"

RSpec.describe "Variant library", type: :request do
  let!(:variant) { Variant.create!(name: "Archie", family: "Draw", game_type: "Big-Bet", split_pot: "Yes", final_hand: "High and low", max_players: "6") }

  it "lists and filters variants" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Archie")
    get variants_path, params: { family: "Stud" }
    expect(response.body).to include("No variants found")
    expect(response.body).not_to include("<h3>Archie</h3>")
    get variants_path, params: { q: "archie", split_pot: "Yes" }
    expect(response.body).to include("Archie")
  end

  it "shows the complete rules and both forms" do
    get variant_path(variant)
    expect(response.body).to include("High and low", "Edit variant")
    get new_variant_path
    expect(response).to have_http_status(:ok)
    get edit_variant_path(variant)
    expect(response.body).to include("Archie", "Save changes")
  end

  it "creates, updates, and deletes a persisted variant" do
    expect { post variants_path, params: { variant: { name: "House game", family: "Stud", game_type: "Fixed-Limit", source_notes: "House rules" } } }.to change(Variant, :count).by(1)
    created = Variant.order(:id).last
    expect(response).to redirect_to(variant_path(created))
    patch variant_path(created), params: { variant: { name: "New house game", max_players: "8" } }
    expect(created.reload.name).to eq("New house game")
    expect(created.max_players).to eq("8")
    expect { delete variant_path(created) }.to change(Variant, :count).by(-1)
    expect(response).to redirect_to(variants_path)
  end

  it "rejects missing required fields and invalid counts without losing input" do
    expect { post variants_path, params: { variant: { name: "Invalid game", family: "", game_type: "Big-Bet", max_players: "-1" } } }.not_to change(Variant, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Invalid game", "Family", "greater than 0")
    patch variant_path(variant), params: { variant: { name: "" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(variant.reload.name).to eq("Archie")
  end

  it "exports all 27 spreadsheet columns and neutralizes spreadsheet formulas" do
    variant.update!(source_notes: "=1+1")
    get variants_path(format: :csv), params: { family: "Draw" }
    rows = CSV.parse(response.body)
    expect(rows.first).to eq(Variant::FIELDS.values)
    expect(rows.last.first).to eq("Archie")
    expect(rows.last.last).to eq("'=1+1")
  end

  it "escapes user content" do
    variant.update!(name: "<script>alert(1)</script>")
    get variant_path(variant)
    expect(response.body).to include("&lt;script&gt;")
    expect(response.body).not_to include("<script>alert(1)</script>")
  end
end
