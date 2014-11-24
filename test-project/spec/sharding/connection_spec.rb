RSpec.describe DbCharmer::Sharding::Connection do
  describe "in constructor" do
    it "should not fail if method name is correct" do
      expect { DbCharmer::Sharding::Connection.new(name: :foo, method: :range, ranges: {}) }.to_not raise_error
    end

    it "should fail if method name is missing" do
      expect { DbCharmer::Sharding::Connection.new(name: :foo) }.to raise_error(ArgumentError)
    end

    it "should fail if method name is invalid" do
      expect { DbCharmer::Sharding::Connection.new(name: :foo, method: :foo) }.to raise_error(NameError)
    end

    it "should instantiate a sharder class according to the :method value" do
      expect(DbCharmer::Sharding::Method::Range).to receive(:new)
      DbCharmer::Sharding::Connection.new(name: :foo, method: :range, ranges: {})
    end
  end
end

