# frozen_string_literal: true

module Projects
  class IntegrationsController < ApplicationController
    before_action :set_project, only: %i[index show new edit create update]
    before_action :set_integration, only: %i[show edit update]

    def index
      @integrations = Integration.where(project: @project)
    end

    def show; end

    def new
      @integration = Integration.new(project: @project)
    end

    def edit; end

    def create
      @integration = Integration.new(integration_params)
      @integration.project = @project

      if @integration.save
        redirect_to organization_project_path(@project.organization, @project),
                    notice: 'Integration was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @integration.update(integration_params)
        redirect_to project_project_path(@integration, @integration), notice: 'Integration was successfully updated.',
                                                                      status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      integration = Integration.find(params.require(:id))
      integration.destroy!

      redirect_back(
        fallback_location: organization_project_path(integration.project),
        notice: 'Integration was successfully destroyed.',
        status: :see_other
      )
    end

    private

    def set_project
      @project = Project.find(params.require(:project_id))
    end

    def set_integration
      @integration = Integration.where(project: @project).find(params.require(:id))
    end

    def integration_params
      params.require(:integration).permit(:name, :origin)
    end
  end
end
