class AvailabilitiesController < ApplicationController
  before_filter :login_required

  def create
    param = {}
    %w(availability_type date_start date_end price_per_night).each do |p|
      param[p.to_sym] = params[p]
    end
    param[:access_token] = current_token
    param[:place_id] = params[:place_id]

    availability = Heypal::Availability.new(param)

    if availability.save
      respond_to do |format|
        format.json { render :json => availability }
      end
    end
  end

  def destroy
    param = {}
    param[:access_token] = current_token
    param[:place_id] = params[:place_id]

    Heypal::Availability.delete(params[:id], param)
  end

  def update
    param = {}
    %w(availability_type date_start date_end price_per_night).each do |p|
      param[p.to_sym] = params[p]
    end
    param[:access_token] = current_token
    param[:place_id] = params[:place_id]
    param[:id] = params[:id]

    if availability = Heypal::Availability.update(param)
      respond_to do |format|
        format.json { render :json => availability }
      end
    end
      
  end
end
