class CardComponentPreview < Lookbook::Preview
  def default
    render CardComponent.new(header: "Header Text") do
      "This is a basic card component."
    end
  end
end
