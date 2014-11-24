RSpec.describe DbCharmer do
  after :each do
    DbCharmer.current_controller = nil
    DbCharmer.connections_should_exist = false
  end

  it "should define version constants" do
    expect(DbCharmer::Version::STRING).to match(/^\d+\.\d+\.\d+/)
  end

  it "should have connections_should_exist accessors" do
    expect(DbCharmer.connections_should_exist).to_not be_nil
    DbCharmer.connections_should_exist = :foo
    expect(DbCharmer.connections_should_exist).to eq(:foo)
  end

  it "should have connections_should_exist? method" do
    DbCharmer.connections_should_exist = true
    expect(DbCharmer.connections_should_exist?).to be(true)
    DbCharmer.connections_should_exist = false
    expect(DbCharmer.connections_should_exist?).to be(false)
    DbCharmer.connections_should_exist = "shit"
    expect(DbCharmer.connections_should_exist?).to be(true)
    DbCharmer.connections_should_exist = nil
    expect(DbCharmer.connections_should_exist?).to be(false)
  end

  it "should have current_controller accessors" do
    expect(DbCharmer.respond_to?(:current_controller)).to be(true)
    DbCharmer.current_controller = :foo
    expect(DbCharmer.current_controller).to eq(:foo)
    DbCharmer.current_controller = nil
  end

  context "in force_slave_reads? method" do
    it "should return true if force_slave_reads=true" do
      expect(DbCharmer.force_slave_reads?).to be(false)

      DbCharmer.force_slave_reads do
        expect(DbCharmer.force_slave_reads?).to be(true)
      end

      expect(DbCharmer.force_slave_reads?).to be(false)
    end

    it "should return false if no controller defined and global force_slave_reads=false" do
      DbCharmer.current_controller = nil
      expect(DbCharmer.force_slave_reads?).to be(false)
    end

    it "should consult with the controller about forcing slave reads if possible" do
      DbCharmer.current_controller = double("controller")

      expect(DbCharmer.current_controller).to receive(:force_slave_reads?).and_return(true)
      expect(DbCharmer.force_slave_reads?).to be(true)

      expect(DbCharmer.current_controller).to receive(:force_slave_reads?).and_return(false)
      expect(DbCharmer.force_slave_reads?).to be(false)
    end
  end

  context "in with_controller method" do
    it "should fail if no block given" do
      expect { DbCharmer.with_controller(:foo) }.to raise_error(ArgumentError)
    end

    it "should switch controller while running the block" do
      DbCharmer.current_controller = nil
      expect(DbCharmer.current_controller).to be_nil

      DbCharmer.with_controller(:foo) do
        expect(DbCharmer.current_controller).to eq(:foo)
      end

      expect(DbCharmer.current_controller).to be_nil
    end

    it "should ensure current controller is reverted to nil in case of errors" do
      expect {
        DbCharmer.with_controller(:foo) { raise "fuck" }
      }.to raise_error
      expect(DbCharmer.current_controller).to be_nil
    end
  end
end
