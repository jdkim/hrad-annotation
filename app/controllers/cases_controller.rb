class CasesController < ApplicationController
  before_action :set_case, only: [ :show, :image, :toggle_done ]

  def index
    @cases = MedicalCase.all.order(Arel.sql("CAST(case_id AS INTEGER)"))
    @done_case_ids = AnnotationStatus.where(user: current_user, done: true).pluck(:medical_case_id).to_set
  end

  def show
    @sce = StructuredCausalExplanation.new
    @sces = @case.structured_causal_explanations.where(user: current_user).order(created_at: :desc)
    @annotation_status = AnnotationStatus.find_or_initialize_by(user: current_user, medical_case: @case)
  end

  def toggle_done
    status = AnnotationStatus.find_or_initialize_by(user: current_user, medical_case: @case)
    status.done = !status.done
    status.save!
    redirect_to case_path(@case.case_id)
  end

  def image
    filename = params[:filename]

    unless @case.image_paths&.include?(filename)
      head :not_found
      return
    end

    image_path = Rails.root.join("data", "case_#{@case.case_id}", filename)

    if File.exist?(image_path)
      content_type = case File.extname(filename).downcase
      when ".png" then "image/png"
      when ".jpg", ".jpeg" then "image/jpeg"
      when ".gif" then "image/gif"
      when ".webp" then "image/webp"
      else "application/octet-stream"
      end

      send_file image_path, type: content_type, disposition: "inline"
    else
      head :not_found
    end
  end

  private

  def set_case
    @case = MedicalCase.find_by!(case_id: params[:case_id])
  end
end
