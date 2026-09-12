require "csv"

class VariantsController < ApplicationController
  before_action :set_variant, only: %i[show edit update destroy]

  def index
    @total = Variant.count
    @family_counts = Variant.group(:family).count
    @split_count = Variant.where(split_pot: "Yes").count
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

  def show
    @previous_variant = Variant.where("id < ?", @variant.id).order(id: :desc).first
    @next_variant = Variant.where("id > ?", @variant.id).order(:id).first

    steps = @variant.sequence_steps
    @variant.source_detail["sequence"] = @variant.source_detail.fetch("sequence", []).reject do |event|
      event["event_name"].to_s.casecmp("Special mechanic").zero?
    end
    initial = @variant.source_detail.fetch("sequence", []).first || {}
    if @variant.name.match?(/Dra.*maha/i)
      @variant.source_detail["sequence"] = ["5 DOWN", "BET", "C C C", "BET", "DRAW", "C", "BET", "C", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    elsif @variant.family == "Stud" && initial["hole_card_count"].to_i == 2 && initial["up_card_count"].to_i == 1
      @variant.source_detail["sequence"] = ["2 DOWN + 1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 DOWN", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    elsif @variant.family == "Stud" && initial["hole_card_count"].to_i == 1 && initial["up_card_count"].to_i == 1
      @variant.source_detail["sequence"] = ["1 DOWN + 1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 UP", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    elsif @variant.name.match?(/\ACrazy Pineapple(?: 8)?\z/i)
      @variant.source_detail["sequence"] = ["3 DOWN", "BET", "C C C", "BET", "DISCARD 1 CARD", "C", "BET", "C", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    elsif @variant.name.match?(/\APineapple(?: 8)?\z/i)
      @variant.source_detail["sequence"] = ["3 DOWN", "DISCARD 1 CARD", "BET", "C C C", "BET", "C", "BET", "C", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    elsif steps.exists?
      @variant.source_detail["sequence"] = steps.map do |step|
        { "event_type" => step.action_type, "event_name" => step.label, "hole_card_count" => step.quantity_unit == "cards" ? step.quantity.to_s : "0", "community_card_count" => step.quantity_unit == "community cards" ? step.quantity.to_s : "0" }
      end
    elsif @variant.name == "7-Card Stud"
      @variant.source_detail["sequence"] = ["2 DOWN + 1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 UP", "BET", "1 DOWN", "BET"].map { |label| { "event_type" => "special", "event_name" => label } }
    end
    draw_max = initial["hole_card_count"].to_i
    draw_max = 5 if draw_max.zero?
    @variant.source_detail["sequence"].map! do |event|
      if event["event_type"].to_s == "draw" && event["event_name"].to_s.match?(/\ADraw\s+\d+\z/i)
        event.merge("event_name" => "#{event['event_name']} 0-#{draw_max}")
      else
        event
      end
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
    params.require(:variant).permit(*Variant::FIELDS.keys, hand_rules_attributes: %i[id rule ace_behavior direction qualifier])
  end

  def csv_value(value)
    value.to_s.match?(/\A[\s]*[=+@-]/) ? "'#{value}" : value
  end
end
