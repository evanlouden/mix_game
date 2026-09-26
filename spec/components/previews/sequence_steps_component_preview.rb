class SequenceStepsComponentPreview < Lookbook::Preview
  # @param variant_id [Integer] "Variant ID to preview"
  def default(variant_id: 2)
    variant = Variant.find(variant_id)
    render SequenceStepsComponent.new(
      sequence: variant.source_detail.fetch("sequence", []),
      variant_name: variant.name
    )
  end
end
