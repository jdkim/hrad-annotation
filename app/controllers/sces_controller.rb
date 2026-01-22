class ScesController < ApplicationController
  before_action :set_case
  before_action :set_sce, only: [ :edit, :update, :destroy ]
  before_action :authorize_sce, only: [ :edit, :update, :destroy ]

  def create
    @sce = @case.structured_causal_explanations.build(sce_params)
    @sce.user = current_user

    if @sce.save
      redirect_to case_path(@case.case_id), notice: "SCE was successfully created."
    else
      redirect_to case_path(@case.case_id), alert: "Error creating SCE: #{@sce.errors.full_messages.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @sce.update(sce_params)
      redirect_to case_path(@case.case_id), notice: "SCE was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sce.destroy
    redirect_to case_path(@case.case_id), notice: "SCE was successfully deleted."
  end

  private

  def set_case
    @case = MedicalCase.find_by!(case_id: params[:case_case_id])
  end

  def set_sce
    @sce = @case.structured_causal_explanations.find(params[:id])
  end

  def authorize_sce
    unless @sce.user == current_user
      redirect_to case_path(@case.case_id), alert: "You can only modify your own SCEs."
    end
  end

  def sce_params
    params.require(:structured_causal_explanation).permit(:finding, :impression, :certainty)
  end
end
