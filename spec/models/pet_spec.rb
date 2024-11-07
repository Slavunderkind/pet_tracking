require 'rails_helper'

RSpec.describe Pet do
  before(:all) do
    @redis = Redis.new
    @redis.flushdb # Clear the Redis database before tests
  end

  after(:all) do
    @redis.flushdb # Clean up after tests
  end

  let(:pet_attributes) do
    {
      id: 1,
      type: 'dog',
      tracker_type: 'GPS',
      owner_id: 'owner123',
      in_zone: true,
      lost_tracker: false
    }
  end

  let(:pet) { Pet.new(pet_attributes) }
  let(:pet1) { Pet.new(pet_attributes) }

  describe '#save' do
    it 'saves a pet to Redis' do
      pet.save

      stored_data = @redis.hgetall(pet.redis_key)
      expect(stored_data['id']).to eq(pet.id.to_s)
      expect(stored_data['type']).to eq(pet.type)
      expect(stored_data['tracker_type']).to eq(pet.tracker_type)
      expect(stored_data['owner_id']).to eq(pet.owner_id)
      expect(stored_data['in_zone']).to eq('1')
      expect(stored_data['lost_tracker']).to eq('0')
    end
  end

  describe '.find' do
    it 'retrieves a pet from Redis by ID' do
      pet.save

      found_pet = Pet.find(pet.id)
      expect(found_pet).not_to be_nil
      expect(found_pet.id).to eq(pet.id.to_s)
      expect(found_pet.type).to eq(pet.type)
      expect(found_pet.tracker_type).to eq(pet.tracker_type)
      expect(found_pet.owner_id).to eq(pet.owner_id)
      expect(found_pet.lost_tracker).to eq(0)
    end

    it 'returns nil if the pet does not exist' do
      non_existent_pet = Pet.find(999)
      expect(non_existent_pet).to be_nil
    end
  end

  describe '.all' do
  	let(:pet2) { Pet.new(pet_attributes.merge(id: 2, type: 'cat', in_zone: false)) }

  	before do
    	pet1.save
    	pet2.save
    end
    it 'retrieves all pets from Redis' do
      all_pets = Pet.all
      expect(all_pets.size).to eq(2)
      expect(all_pets.map(&:id)).to contain_exactly(pet1.id.to_s, pet2.id.to_s)
    end
  end

  describe '.count_out_of_zone' do
  	let(:pet2) { Pet.new(pet_attributes.merge(id: 2, in_zone: false)) }

    before do
    	pet1.save
    	pet2.save
    end

    it 'counts the number of pets out of the zone' do
      expect(Pet.count_out_of_zone).to eq(0)
    end
  end

  describe '.count' do
  	let(:pet2) { Pet.new(pet_attributes.merge(id: 2)) }

  	before do
    	pet1.save
    	pet2.save
    end

    it 'counts the total number of pets' do
      expect(Pet.count).to eq(2)
    end
  end
end
