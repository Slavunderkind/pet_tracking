require 'pry'

class Api::PetsController < ApplicationController
	before_action :set_pet, only: %i[show]

	# GET /api/pets
  def index
    Pet.all
  end

  # GET /api/pets/:id
  def show
    if @pet
      render json: @pet
    else
      render json: { error: "Pet not found" }, status: :not_found
    end
  end

	# POST /api/pets
  def create
    id = $redis.incr("pet_id") # Auto-increment pet ID
    pet = Pet.new(pet_params.merge!({id: id}))
    pet.save
    render json: pet, status: :created
  end

	private

	def set_pet
    @pet = Pet.find(params[:id]) || nil
	end

	def pet_params
		params.require(:pet).permit(
			:type,
		  :tracker_type,
		  :owner_id,
		  :in_zone,
		  :lost_tracker
	 	)
	end
end
