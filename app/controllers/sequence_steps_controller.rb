class SequenceStepsController < ApplicationController
  before_action :set_variant
  before_action :set_sequence_step, only: %i[edit update destroy]

  def new
    @sequence_step = @variant.sequence_steps.new(position: @variant.sequence_steps.maximum(:position).to_i + 1, action_type: "betting")
  end

  def create
    @sequence_step = @variant.sequence_steps.new(sequence_step_params)
    @variant.transaction do
      raise ActiveRecord::Rollback unless save_in_sequence(@sequence_step)
    end

    if @sequence_step.persisted?
      redirect_to @variant, notice: "Sequence step added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @sequence_step.assign_attributes(sequence_step_params)
    @variant.transaction do
      raise ActiveRecord::Rollback unless save_in_sequence(@sequence_step)
    end

    if @sequence_step.persisted? && @sequence_step.errors.empty?
      redirect_to @variant, notice: "Sequence step updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sequence_step.destroy!
    redirect_to @variant, status: :see_other, notice: "Sequence step deleted."
  end

  private

  def set_variant
    @variant = Variant.find(params[:variant_id])
  end

  def set_sequence_step
    @sequence_step = @variant.sequence_steps.find(params[:id])
  end

  def sequence_step_params
    params.require(:sequence_step).permit(:position, :action_type, :card_scope, :number_of_boards, :cards_down, :cards_up, :min_cards, :max_cards)
  end

  def save_in_sequence(step)
    return false unless step.valid?

    desired_position = step.position.to_i
    other_steps = @variant.sequence_steps.to_a.reject { |candidate| candidate.id == step.id }
    insert_at = [[desired_position - 1, 0].max, other_steps.length].min
    ordered_steps = other_steps.insert(insert_at, step)

    ordered_steps.each_with_index do |candidate, index|
      candidate.update_columns(position: -(index + 1)) if candidate.persisted?
    end

    step.position = insert_at + 1
    return false unless step.save

    ordered_steps.each_with_index do |candidate, index|
      candidate.update_columns(position: index + 1)
    end

    true
  end
end
