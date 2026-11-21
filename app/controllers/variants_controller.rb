require "csv"

class VariantsController < ApplicationController
  before_action :set_variant, only: %i[show edit update destroy generate_flop_sequence generate_stud_sequence]
  before_action :require_admin!, only: %i[new create edit update destroy generate_flop_sequence generate_stud_sequence]

  def index
    @total = Variant.count
    @family_counts = Variant.group(:family).count
    @split_count = Variant.where.not(pot_2_hand_rule: [nil, ""]).count
    @player_options = Variant.where.not(max_players: [nil, ""]).distinct.pluck(:max_players).sort_by(&:to_i)
    @variants = Variant.filtered(params)
    @count = @variants.count
    respond_to do |format|
      format.html do
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
    scope = params[:bomb_pot] == "Yes" ? Variant.bomb_pot_eligible : Variant.filtered(params)
    variant = scope.reorder(Arel.sql("RANDOM()")).first

    if variant
      style = Variant::BOARD_STYLE_COUNTS.keys.sample if variant.board_style_eligible?
      redirect_to variant_path(variant, style: style)
    else
      redirect_to variants_path(request.query_parameters.except("action", "controller")), alert: "No variants match those filters."
    end
  end

  def show
    @board_style = params[:style] if Variant::BOARD_STYLE_COUNTS.key?(params[:style]) && @variant.board_style_eligible?
    @board_style_label = Variant::MODIFIERS[@board_style]
    @derailment = @board_style == "derailment"
    @effective_modifiers = @variant.modifiers.to_a.dup
    @effective_modifiers << @board_style if @board_style && !@effective_modifiers.include?(@board_style)
    @board_style_description = Variant::MODIFIER_DESCRIPTIONS[@board_style]
    @sequence = @variant.sequence_steps.map do |step|
      community_count = step.card_scope == "community" ? step.cards_up.to_i : 0
      board_count = step.number_of_boards.to_i
      if @board_style && step.action_type == "deal" && step.card_scope == "community"
        board_count = Variant::BOARD_STYLE_COUNTS[@board_style]
        community_count *= board_count
      end
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
      { "event_type" => event_type, "action_type" => step.action_type, "event_name" => event_name, "hole_card_count" => step.card_scope == "individual" ? step.cards_down.to_s : "0", "up_card_count" => step.card_scope == "individual" ? step.cards_up.to_s : "0", "community_card_count" => community_count.to_s, "min_cards" => step.min_cards, "max_cards" => step.max_cards }
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

  def generate_flop_sequence
    StandardFlopSequence.call(@variant)
    redirect_to @variant, notice: "Standard flop sequence generated."
  end

  def generate_stud_sequence
    StandardStudSequence.call(@variant)
    redirect_to @variant, notice: "Standard stud sequence generated."
  end

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
    permitted = params.require(:variant).permit(*Variant::FIELDS.keys, modifiers: [])
    permitted[:modifiers] = permitted.fetch(:modifiers, []).reject(&:blank?)
    permitted
  end

  def csv_value(value)
    value.to_s.match?(/\A[\s]*[=+@-]/) ? "'#{value}" : value
  end
end
