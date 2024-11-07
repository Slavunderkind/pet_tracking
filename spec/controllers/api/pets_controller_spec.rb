require 'rails_helper'

RSpec.describe Api::PetsController, type: :controller do
  let(:valid_attributes) do
    {
      id: 1,
      type: "Cat",
      tracker_type: "big",
      owner_id: "124",
      in_zone: true,
      lost_tracker: 0
    }
  end

  let(:invalid_attributes) do
    {
      type: nil,
      tracker_type: nil,
      owner_id: nil
    }
  end

  let(:pet) { Pet.new(valid_attributes) }

  describe "GET #index" do
    before { pet.save }

    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "returns all pets as JSON" do
      get :index
      expect(JSON.parse(response.body).first['type']).to eq("Cat")
    end
  end

  describe "GET #show" do
    context "when the pet exists" do
      it "returns the pet as JSON" do
        get :show, params: { id: pet.id }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["id"].to_i).to eq(pet.id)
      end
    end

    context "when the pet does not exist" do
      it "returns a not found response" do
        get :show, params: { id: 9999 } # Assuming this ID doesn't exist
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "error" => "Pet not found" })
      end
    end
  end

  describe "GET #outside_zone" do
    it "returns the count of pets outside the tracking zone" do
      allow(Pet).to receive(:count_out_of_zone).and_return(3)
      get :outside_zone
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("Pets outside the tracking zone are currently 3")
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Pet" do
        expect {
          post :create, params: { pet: valid_attributes }
        }.to change(Pet, :count).by(1)
      end

      it "returns the created pet as JSON" do
        post :create, params: { pet: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["type"]).to eq("Cat")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Pet" do
        expect {
          post :create, params: { pet: invalid_attributes }
        }.not_to change(Pet, :count)
      end

      it "returns an error response" do
        post :create, params: { pet: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
