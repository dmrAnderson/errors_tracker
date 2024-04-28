# frozen_string_literal: true

module Organizations
  class ProjectsController < ApplicationController
    before_action :set_organization
    before_action :set_project, only: %i[show edit update destroy]

    def index
      @projects = Project.where(organization: @organization)
    end

    def show; end

    def new
      @project = Project.new(organization: @organization)
    end

    def edit; end

    def create
      @project = Project.new(project_params)
      @project.organization = @organization

      if @project.save
        redirect_to organization_project_path(@organization, @project), notice: 'Project was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @project.update(project_params)
        redirect_to organization_project_path(@organization, @project), notice: 'Project was successfully updated.',
                                                                        status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @project.destroy!
      redirect_to organization_projects_path(@organization), notice: 'Project was successfully destroyed.',
                                                             status: :see_other
    end

    private

    def set_organization
      @organization = Organization.find(params.require(:organization_id))
    end

    def set_project
      @project = Project.where(organization: @organization).find(params.require(:id))
    end

    def project_params
      params.require(:project).permit(:name)
    end
  end
end
