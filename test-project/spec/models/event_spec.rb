RSpec.describe Event, "sharded model" do
  fixtures :event_shards_info, :event_shards_map

  it "should respond to shard_for method" do
    expect(Event).to respond_to(:shard_for)
  end

  it "should correctly switch shards" do
    # Cleanup sharded tables
    Event.on_each_shard { |event| event.delete_all }

    # Check that they are empty
    expect(Event.shard_for(2).all).to be_empty
    expect(Event.shard_for(12).all).to be_empty

    # Create some data (one record in each shard)
    Event.shard_for(2).create!(
      from_uid: 1,
      to_uid: 2,
      original_created_at: Time.now,
      event_type: 1,
      event_data: 'foo'
    )
    Event.shard_for(12).create!(
      from_uid: 1,
      to_uid: 12,
      original_created_at: Time.now,
      event_type: 1,
      event_data: 'bar'
    )

    # Check sharded tables to make sure they have the data
    expect(Event.shard_for(2).find_all_by_from_uid(1).map(&:event_data)).to eq([ 'foo' ])
    expect(Event.shard_for(12).find_all_by_from_uid(1).map(&:event_data)).to eq([ 'bar' ])
  end

  it "should allocate new blocks when needed" do
    # Cleanup sharded tables
    Event.on_each_shard { |event| event.delete_all }

    # Check new block, it should be empty
    expect(Event.shard_for(100).count).to be_zero

    # Create an object
    Event.shard_for(100).create!(
      from_uid: 1,
      to_uid: 100,
      original_created_at: Time.now,
      event_type: 1,
      event_data: 'blah'
    )

    # Check the new block
    expect(Event.shard_for(100).count).to eq(1)
  end

  it "should fail to perform any database operations w/o a shard specification" do
    allow(Event).to receive(:column_defaults).and_return({})
    allow(Event).to receive(:columns_hash).and_return({})

    expect(lambda { Event.first }).to raise_error(ActiveRecord::ConnectionNotEstablished)
    expect(lambda { Event.create }).to raise_error(ActiveRecord::ConnectionNotEstablished)
    expect(lambda { Event.delete_all }).to raise_error(ActiveRecord::ConnectionNotEstablished)
  end

  it "should not fail when AR does some internal calls to the database" do
    # Cleanup sharded tables
    Event.on_each_shard { |event| event.delete_all }

    # Create an object
    x = Event.shard_for(100).create!(
      from_uid: 1,
      to_uid: 100,
      original_created_at: Time.now,
      event_type: 1,
      event_data: 'blah'
    )

    Event.reset_column_information
    expect(lambda { x.inspect }).to_not raise_error
  end
end
