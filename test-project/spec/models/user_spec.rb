RSpec.describe User do
  before :each do
    @valid_attributes = {
      login:    "value for login",
      password: "value for password",
    }
    User.switch_connection_to(nil)
    User.db_charmer_default_connection = nil
  end

  it "should create a new instance given valid attributes" do
    User.create!(@valid_attributes)
  end

  it "should create a new instance in a specified db" do
    # Just to make sure
    expect(User.on_db(:user_master).connection.object_id).to_not eq(User.connection.object_id)

    # Default connection should not be touched
    expect(User.connection).to_not receive(:insert)

    # Only specified connection receives an insert
    expect(User.on_db(:user_master).connection).to receive(:insert)

    # Test!
    User.on_db(:user_master).create!(@valid_attributes)
  end
end
