RSpec.describe RangeShardedModel do
  describe "class method shard_for" do
    describe "should correctly set shards in range-defined shards" do
      [ 0, 1, 50, 99].each do |id|
        it "for #{id}" do
          RangeShardedModel.shard_for(id) do |m|
            expect(m.connection.object_id).to eq(RangeShardedModel.on_db(:shard1).connection.object_id)
          end
        end
      end

      [ 100, 101, 150, 199, 200].each do |id|
        it "for #{id}" do
          RangeShardedModel.shard_for(id) do |m|
            expect(m.connection.object_id).to eq(RangeShardedModel.on_db(:shard2).connection.object_id)
          end
        end
      end
    end

    describe "should correctly set shards in default shard" do
      [ 201, 500].each do |id|
        it "for #{id}" do
          RangeShardedModel.shard_for(id) do |m|
            expect(m.connection.object_id).to eq(RangeShardedModel.on_db(:shard3).connection.object_id)
          end
        end
      end
    end

    it "should raise an exception when there is no default shard and no ranged shards matched" do
      begin
        default_shard = RangeShardedModel.sharded_connection.sharder.ranges.delete(:default)
        expect(lambda { RangeShardedModel.shard_for(500) }).to raise_error(ArgumentError)
      ensure
        RangeShardedModel.sharded_connection.sharder.ranges[:default] = default_shard
      end
    end
  end
end

