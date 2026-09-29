require "csv"

class VariantsController < ApplicationController
  before_action :set_variant, only: %i[show edit update destroy]

  def index
    @total = Variant.count
    @family_counts = Variant.group(:family).count
    @split_count = Variant.where.not(pot_2_hand_rule: [nil, ""]).count
    @variants = Variant.filtered(params)
    @count = @variants.count
    respond_to do |format|
      format.html do
        @pages = [ (@count / 24.0).ceil, 1 ].max
        @page = params[:page].to_i.clamp(1, @pages)
        @variants = @variants.offset((@page - 1) * 24).limit(24)
      end
      format.csv do
        csv = CSV.generate do |output|
          output << Variant::FIELDS.values
          @variants.each { |variant| output << Variant::FIELDS.keys.map { |field| csv_value(variant.public_send(field)) } }
        end
        send_data csv, filename: "poker-variants-#{Date.current}.csv", type: "text/csv"
      end
    end
  end

  def random
    variant = Variant.order("RANDOM()").first

    if variant
      redirect_to variant
    else
      redirect_to variants_path, alert: "No variants are available yet."
    end
  end

  def show
    @sequence = @variant.sequence_steps.map do |step|
      community_count = step.card_scope == "community" ? step.cards_up.to_i : 0
      board_count = step.number_of_boards.to_i
      step_label = case step.action_type
      when "betting" then "Bet"
      when "draw" then "Draw"
      when "discard" then "Discard"
      when "expose", "reveal" then "Expose #{step.cards_up.to_i} Cards"
      when "deal" then step.card_scope == "community" ? "Community" : "Deal"
      else step.action_type.humanize
      end
      event_name = if board_count > 1 && community_count.positive?
        base_count, remainder = community_count.divmod(board_count)
        board_counts = Array.new(board_count, base_count)
        remainder.times { |index| board_counts[index] += 1 }
        board_counts.map { |count| (["C"] * count).join(" ") }.join("||")
      else
        step_label
      end
      event_type = board_count > 1 && community_count.positive? ? "special" : (step.card_scope == "community" ? "deal" : step.action_type)
      { "event_type" => event_type, "event_name" => event_name, "hole_card_count" => step.card_scope == "individual" ? step.cards_down.to_s : "0", "up_card_count" => step.card_scope == "individual" ? step.cards_up.to_s : "0", "community_card_count" => community_count.to_s, "min_cards" => step.min_cards, "max_cards" => step.max_cards }
    end
  end
  def new
    @variant = Variant.new
  end

  def create
    @variant = Variant.new(variant_params)
    if @variant.save
      redirect_to @variant, notice: "Variant added to your library."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end
  def update
    if @variant.update(variant_params)
      redirect_to @variant, notice: "Variant updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @variant.destroy!
    redirect_to variants_path, status: :see_other, notice: "Variant deleted."
  end

  private

  def set_variant
    @variant = Variant.find(params[:id])
  end

  def variant_params
    params.require(:variant).permit(*Variant::FIELDS.keys)
  end

  def csv_value(value)
    value.to_s.match?(/\A[\s]*[=+@-]/) ? "'#{value}" : value
  end
end
