class EntitiesController < ApplicationController
  def index
    @entities = Entity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @entities }
    end
  end

  def new
    @entity = Entity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @entity }
    end
  end

  def create
    form_data = params[:entity]
    begin
      entity = Entity.create!(form_data)
    rescue
      respond_to do |format|
        format.html { redirect_to entities_path, alert: 'Failed to create entity' }
        format.json { render :json => entity.errors, :status => :unprocessable_entity }
      end

      return
    end
 
    respond_to do |format|
      format.html { redirect_to entities_path, notice: 'Entity created successfully.' }
      format.json { render :json => entity, :status => :created, :location => entities_path }
    end
  end

  def edit
    @entity = Entity.find(params[:id])    
  end

  def update
    @entity = Entity.find(params[:id])
    form_data = params[:entity]

    @entity.update_attributes!(form_data)
    redirect_to entities_path, notice: 'Entity edited successfully.'
  end

  def destroy
    @entity = Entity.find(params[:id])
    @entity.delete

    redirect_to entities_path, notice: 'Entity deleted successfully.'
  end
end
