# The Mix — entity relationship diagram

```mermaid
erDiagram
  USERS {
    bigint id PK
    string email UK
    string encrypted_password
    datetime remember_created_at
    datetime reset_password_sent_at
    string reset_password_token UK
    datetime created_at
    datetime updated_at
  }

  VARIANTS {
    bigint id PK
    string source_id UK
    string name
    string game_type
    string family
    text max_players
    text forced_bet
    text bring_in
    text raise_to_open
    text betting_structure
    text betting_rounds
    text starting_cards
    text initial_up_cards
    text community_board
    text draw_count
    text draw_details
    text discard_details
    text split_pot
    text qualifier
    text high_hand
    text low_hand
    text final_hand
    text wild_cards
    text deck_modification
    text action_order
    text special_mechanics
    text best_hand
    text source_pages
    text source_notes
    jsonb source_detail
    datetime created_at
    datetime updated_at
  }

  SEQUENCE_STEPS {
    bigint id PK
    bigint variant_id FK
    integer position
    string action_type
    string label
    integer quantity
    string quantity_unit
    text details
    string source_pages
    jsonb metadata
    datetime created_at
    datetime updated_at
  }

  HAND_RULES {
    bigint id PK
    bigint variant_id FK
    integer pot_number
    string direction
    string hand_type
    integer hand_size
    integer hole_cards_required
    integer community_cards_required
    string rule
    string qualifier
    text notes
    string source_pages
    datetime created_at
    datetime updated_at
  }

  VARIANTS ||--o{ SEQUENCE_STEPS : "has ordered steps"
  VARIANTS ||--o{ HAND_RULES : "has rules per pot"
```

`USERS` is retained from the starter Devise setup. The library itself is currently shared and does not associate variants with users.

`VARIANTS` stores the spreadsheet’s 27 editable fields. `SEQUENCE_STEPS` is an ordered, flexible child collection for deal, betting, draw, discard, separate, and special actions. `HAND_RULES` stores one or more hand-construction rules for each pot; games without a restriction can use the default “best five cards” behavior.
