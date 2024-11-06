require 'pry'

class Api::PetsController < ApplicationController
	before_action :set_pet, only: %i[show]

	# GET /api/pets
  def index
    keys = $redis.keys("pet:*")
    pets = keys.map { |key| JSON.parse($redis.get(key)) }
    render json: pets
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

  def show
  end

	private

	def set_pet
		pet_data = $redis.get("pet:#{params[:id]}")
    @pet = pet_data ? JSON.parse(pet_data) : nil
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
