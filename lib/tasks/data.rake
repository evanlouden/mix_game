namespace :db do
  namespace :data do
    desc "Export variants and sequence steps to db/data/current_state.json"
    task export: :environment do
      output_path = Rails.root.join("db/data/current_state.json")

      payload = {
        "variants" => Variant.order(:id).map do |variant|
          variant.attributes.slice(*Variant.column_names)
        end,
        "sequence_steps" => SequenceStep.order(:variant_id, :position, :id).map do |step|
          step.attributes.slice(*SequenceStep.column_names)
        end
      }

      File.write(output_path, JSON.pretty_generate(payload) + "\n")
      puts "Exported #{payload["variants"].size} variants and #{payload["sequence_steps"].size} sequence steps to #{output_path}"
    end

    desc "Import variants and sequence steps from db/data/current_state.json"
    task import: :environment do
      input_path = Rails.root.join(ENV.fetch("FILE", "db/data/current_state.json"))
      payload = JSON.parse(input_path.read)

      Variant.transaction do
        payload.fetch("variants").each do |attributes|
          variant = Variant.find_or_initialize_by(id: attributes.fetch("id"))
          variant.assign_attributes(attributes.except("id", "created_at", "updated_at"))
          variant.save!
        end

        SequenceStep.transaction do
          payload.fetch("sequence_steps").each do |attributes|
            step = SequenceStep.find_or_initialize_by(id: attributes.fetch("id"))
            step.assign_attributes(attributes.except("id", "created_at", "updated_at"))
            step.save!
          end
        end
      end

      puts "Imported #{payload.fetch("variants").size} variants and #{payload.fetch("sequence_steps").size} sequence steps from #{input_path}"
    end
  end
end
