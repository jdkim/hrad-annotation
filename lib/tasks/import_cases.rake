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

      case_id = File.basename(case_folder).sub(/\Acase_/, "")
      puts "Processing case: #{case_id}"

      # Read report.txt
      report_path = File.join(case_folder, "report.txt")
      report_text = File.exist?(report_path) ? File.read(report_path).strip : nil

      # Read causal exploration.txt
      causal_path = File.join(case_folder, "causal exploration.txt")
      causal_text = File.exist?(causal_path) ? File.read(causal_path).strip : nil

      # Parse ABCDE checklist (XLSX or CSV)
      checklist_data = nil
      xlsx_path = File.join(case_folder, "ABCDE checklist.xlsx")
      csv_path = File.join(case_folder, "ABCDE checklist.csv")

      if File.exist?(xlsx_path)
        checklist_data = parse_xlsx_checklist(xlsx_path)
      elsif File.exist?(csv_path)
        csv_data = CSV.read(csv_path, headers: true)
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

  desc "Seed initial annotations by extracting finding/impression pairs from causal exploration text using Claude API"
  task seed_annotations: :environment do
    require "anthropic"

    api_key = ENV["ANTHROPIC_API_KEY"]
    unless api_key
      puts "Error: ANTHROPIC_API_KEY not set in .env"
      exit 1
    end

    client = Anthropic::Client.new(api_key: api_key)
    user = User.initial_annotator
    count = 0
    skipped = 0

    MedicalCase.order(Arel.sql("CAST(case_id AS INTEGER)")).each do |medical_case|
      if medical_case.structured_causal_explanations.where(user: user).exists?
        skipped += 1
        next
      end

      text = medical_case.causal_exploration_text
      unless text.present?
        puts "  Case #{medical_case.case_id}: No causal exploration text, skipping."
        skipped += 1
        next
      end

      pairs = extract_finding_impression_pairs(client, text)

      if pairs.empty?
        puts "  Case #{medical_case.case_id}: No pairs extracted, creating placeholder."
        medical_case.structured_causal_explanations.create!(
          user: user, finding: "N/A", impression: "N/A", certainty: false
        )
        count += 1
      else
        pairs.each do |pair|
          medical_case.structured_causal_explanations.create!(
            user: user,
            finding: pair["finding"],
            impression: pair["impression"],
            certainty: false
          )
          count += 1
        end
        puts "  Case #{medical_case.case_id}: #{pairs.size} pair(s) extracted."
      end
    end

    puts "Done. Created #{count} annotations, skipped #{skipped} cases."
  end
end

def extract_finding_impression_pairs(client, causal_text)
  prompt = <<~PROMPT
    Extract all causal statements from the following radiology causal exploration text.
    For each causal statement, identify:
    - "finding": the observed radiological sign or observation (what is seen on the image)
    - "impression": the diagnostic interpretation or conclusion (what it means)

    Return a JSON array of objects with "finding" and "impression" keys.
    Return ONLY the JSON array, no other text.

    Example input: "The minimal blunting of the right costophrenic angle further supports the presence of a small effusion."
    Example output: [{"finding": "minimal blunting of the right costophrenic angle", "impression": "small pleural effusion"}]

    Text:
    #{causal_text}
  PROMPT

  response = client.messages.create(
    model: "claude-sonnet-4-20250514",
    max_tokens: 1024,
    messages: [{ role: "user", content: prompt }]
  )

  json_text = response.content.first.text.strip
  # Extract JSON array if wrapped in markdown code block
  json_text = json_text[/\[.*\]/m] || "[]"
  JSON.parse(json_text)
rescue JSON::ParserError => e
  puts "    JSON parse error: #{e.message}"
  []
rescue => e
  puts "    API error: #{e.message}"
  []
end

def parse_xlsx_checklist(path)
  require "roo"
  xlsx = Roo::Spreadsheet.open(path)
  sheet = xlsx.sheet(0)

  headers = sheet.row(1).map { |h| h.to_s.strip }
  data_row = sheet.row(2)

  row_hash = {}
  headers.each_with_index do |header, i|
    next if header.empty?
    value = data_row[i]
    row_hash[header] = value.is_a?(Numeric) ? value.to_i : value
  end

  [ row_hash ]
end
