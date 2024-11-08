require "redis"

class Pet
  # enum type: [ :dog, :cat ]
  BOOLEAN_IN_REDIS = {
    true: 1,
    false: 0
  }.freeze

  # Initialize Redis client
  @@redis = Redis.new

  attr_accessor :id, :type, :tracker_type, :owner_id, :in_zone, :lost_tracker

  def initialize(attributes = {})
    @id = attributes[:id] || SecureRandom.uuid
    @type = attributes[:type]
    @tracker_type = attributes[:tracker_type]
    @owner_id = attributes[:owner_id]
    @in_zone = parse_boolean(attributes[:in_zone])
    @lost_tracker = parse_boolean(attributes[:lost_tracker]) || 0
  end

  # Save the pet to Redis
  def save
    @@redis.hmset(redis_key, "id", @id, "type", @type, "tracker_type", @tracker_type, "owner_id", @owner_id, "in_zone", @in_zone, "lost_tracker", @lost_tracker)
  end

  def self.all
    all_keys = @@redis.keys("*")
    all_keys.map { |key| find(key.split(":").last.to_i) }
  end

  # Find a pet by ID
  def self.find(id)
    data = @@redis.hgetall("pet:#{id}")
    return nil if data.empty?
    new(id: data["id"], type: data["type"], tracker_type: data["tracker_type"], owner_id: data["owner_id"], in_zone: data["in_zone"], lost_tracker: data["lost_tracker"])
  end

  def self.count_out_of_zone
    all.count { |pet| pet.in_zone == '0' }
  end

  def self.count
    all.count
  end

  # Redis key for the pet
  def redis_key
    "pet:#{@id}"
  end

  private

  def parse_boolean(value)
    return value unless value.in? [true, false]

    BOOLEAN_IN_REDIS[:"#{value}"]
  end
end
