require "csv"

namespace :cases do
  desc "Import cases from the data folder"
  task import: :environment do
    data_dir = Rails.root.join("data")

    unless Dir.exist?(data_dir)
      puts "Data directory not found: #{data_dir}"
      exit 1
    end

    Dir.glob(File.join(data_dir, "*")).each do |case_folder|
      next unless File.directory?(case_folder)

      case_id = File.basename(case_folder)
      puts "Processing case: #{case_id}"

      # Read report.txt
      report_path = File.join(case_folder, "report.txt")
      report_text = File.exist?(report_path) ? File.read(report_path).strip : nil

      # Read causal exploration.txt
      causal_path = File.join(case_folder, "causal exploration.txt")
      causal_text = File.exist?(causal_path) ? File.read(causal_path).strip : nil

      # Parse ABCDE checklist.csv
      checklist_path = File.join(case_folder, "ABCDE checklist.csv")
      checklist_data = nil
      if File.exist?(checklist_path)
        csv_data = CSV.read(checklist_path, headers: true)
        checklist_data = csv_data.map(&:to_h)
      end

      # Find image files
      image_extensions = %w[.png .jpg .jpeg .gif .bmp .webp]
      image_paths = Dir.glob(File.join(case_folder, "*")).select do |f|
        image_extensions.include?(File.extname(f).downcase)
      end.map { |f| File.basename(f) }

      # Create or update the case
      medical_case = MedicalCase.find_or_initialize_by(case_id: case_id)
      medical_case.assign_attributes(
        report_text: report_text,
        causal_exploration_text: causal_text,
        checklist_data: checklist_data,
        image_paths: image_paths
      )

      if medical_case.save
        puts "  - Saved case #{case_id} with #{image_paths.size} image(s)"
      else
        puts "  - Error saving case #{case_id}: #{medical_case.errors.full_messages.join(', ')}"
      end
    end

    puts "Import completed. Total cases: #{MedicalCase.count}"
  end
end
