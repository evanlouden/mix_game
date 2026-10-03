# The Mix

A Rails CRUD library for poker variants, built from `poker_variant_mechanics_normalized.xlsx`.

- 241 imported variants across Draw, Hold’em, Omaha, and Stud.
- Create, browse, edit, and delete games; all 27 columns in the Variants sheet are editable.
- Search names, final-hand rules, and special mechanics. Filter by family, betting type, and split pot, with 24 games per page.
- Export the filtered library as CSV using the original column names.
- Reference the original game sequences, hand rules, mechanic tags, normalized model, source index, and raw page text on each imported variant.
- Responsive layouts, validation errors, and deletion confirmation.

## Run locally

Requires Ruby 3.4.7, Node, and PostgreSQL (the existing app uses PostgreSQL).

```sh
bundle install
npm install
npm run build
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Open http://localhost:3000. PostgreSQL must be running with a role matching your local username, or supply `DATABASE_URL` for your database. The defaults are `poker_mix_game_development` and `poker_mix_game_test`.

`bin/dev` starts Rails. Run `npm run build -- --watch` separately while changing JavaScript. The interface uses plain CSS and does not need a Tailwind build.

## Spreadsheet data

`db/data/workbook.json` preserves all eight sheets, generated with the Python standard library:

```sh
python3 script/extract_workbook.py
bin/rails db:seed
```

Seeds use the normalized sheet’s stable `variant_id`, so names shared across betting categories remain separate. Re-running seeds skips existing imported records and preserves edits. It restores deleted workbook records; run seeds only when you intend to populate the library. New app-created records have no source ID.

Blank workbook cells stay unknown rather than becoming inferred rules. Some supplied fields contain extraction artifacts or truncated text; these are preserved. Edit the main fields to correct them. Supporting material is a read-only snapshot of the original import and does not change when the editable rules change. Field definitions and every source sheet are also retained in the JSON export.

CSV export covers the 27 editable fields. Potential spreadsheet formulas are prefixed with an apostrophe for safe opening.

## Verification

```sh
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
bundle exec rubocop app/models/variant.rb app/controllers/variants_controller.rb db/migrate/20260910000000_create_variants.rb db/seeds.rb spec/requests/variants_spec.rb
```

The library is public to browse, while detailed sequence steps, variant attributes, and editing are restricted to signed-in users. Devise sign-in is intentionally not linked in the public interface; use `/users/sign_in` directly. Public registration is disabled. To create the first admin locally or in production, open a Rails console and run:

```ruby
User.create!(email: "you@example.com", password: "use-a-strong-password", admin: true)
```

Only admin users can create, edit, or delete variants and sequence steps. Authorization is enforced in the controllers as well as reflected in the interface.
