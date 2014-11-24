RSpec.describe DbCharmer::Sharding::Method::HashMap do
  SHARDING_MAP = {
    'US'     => :us_users,
    'CA'     => :ca_users,
    :default => :other_users,
  }

  before :each do
    @sharder = DbCharmer::Sharding::Method::HashMap.new(map: SHARDING_MAP)
  end

  describe "standard interface" do
    it "should respond to shard_for_id" do
      expect(@sharder).to respond_to(:shard_for_key)
    end

    it "should return a shard name to be used for an key" do
      expect(@sharder.shard_for_key('US')).to be_kind_of(Symbol)
    end

    it "should support default shard" do
      expect(@sharder.support_default_shard?).to be(true)
    end
  end

  describe "should correctly return shards for all keys defined in the map" do
    SHARDING_MAP.except(:default).each do |key, val|
      it "for #{key}" do
        expect(@sharder.shard_for_key(key)).to eq(val)
      end
    end
  end

  it "should correctly return default shard" do
    expect(@sharder.shard_for_key('UA')).to eq(:other_users)
  end

  it "should raise an exception when there is no default shard and nothing matched" do
    @sharder.map.delete(:default)
    expect(lambda { @sharder.shard_for_key('UA') }).to raise_error(ArgumentError)
  end
end
