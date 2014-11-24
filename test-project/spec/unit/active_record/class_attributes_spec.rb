class FooModel < ActiveRecord::Base; end

RSpec.describe DbCharmer, "for ActiveRecord models" do
  context "in db_charmer_connection_proxy methods" do
    before :each do
      FooModel.db_charmer_connection_proxy = nil
      FooModel.db_charmer_default_connection = nil
    end

    it "should implement both accessor methods" do
      proxy = double('connection proxy')
      FooModel.db_charmer_connection_proxy = proxy
      expect(FooModel.db_charmer_connection_proxy).to be(proxy)
    end
  end

  context "in db_charmer_default_connection methods" do
    before :each do
      FooModel.db_charmer_default_connection = nil
      FooModel.db_charmer_default_connection = nil
    end

    it "should implement both accessor methods" do
      conn = double('connection')
      FooModel.db_charmer_default_connection = conn
      expect(FooModel.db_charmer_default_connection).to be(conn)
    end
  end

  context "in db_charmer_opts methods" do
    before :each do
      FooModel.db_charmer_opts = nil
    end

    it "should implement both accessor methods" do
      opts = { foo: :bar}
      FooModel.db_charmer_opts = opts
      expect(FooModel.db_charmer_opts).to be(opts)
    end
  end

  context "in db_charmer_slaves methods" do
    it "should return [] if no slaves set for a model" do
      FooModel.db_charmer_slaves = nil
      expect(FooModel.db_charmer_slaves).to eq([])
    end

    it "should implement both accessor methods" do
      proxy = double('connection proxy')
      FooModel.db_charmer_slaves = [ proxy ]
      expect(FooModel.db_charmer_slaves).to eq([ proxy ])
    end

    it "should implement random slave selection" do
      FooModel.db_charmer_slaves = [ :proxy1, :proxy2, :proxy3 ]
      srand(0)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy1)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy2)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy1)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy2)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy2)
      expect(FooModel.db_charmer_random_slave).to eq(:proxy3)
    end
  end

  context "in db_charmer_connection_levels methods" do
    it "should return 0 by default" do
      FooModel.db_charmer_connection_level = nil
      expect(FooModel.db_charmer_connection_level).to eq(0)
    end

    it "should implement both accessor methods and support inc/dec operations" do
      FooModel.db_charmer_connection_level = 1
      expect(FooModel.db_charmer_connection_level).to eq(1)
      FooModel.db_charmer_connection_level += 1
      expect(FooModel.db_charmer_connection_level).to eq(2)
      FooModel.db_charmer_connection_level -= 1
      expect(FooModel.db_charmer_connection_level).to eq(1)
    end

    it "should implement db_charmer_top_level_connection? method" do
      FooModel.db_charmer_connection_level = 1
      expect(FooModel).to_not be_db_charmer_top_level_connection
      FooModel.db_charmer_connection_level = 0
      expect(FooModel).to be_db_charmer_top_level_connection
    end
  end

  context "in connection method" do
    it "should return AR's original connection if no connection proxy is set" do
      FooModel.db_charmer_connection_proxy = nil
      FooModel.db_charmer_default_connection = nil
      expect(FooModel.connection).to be_kind_of(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    end
  end

  context "in db_charmer_force_slave_reads? method" do
    it "should use per-model settings when possible" do
      FooModel.db_charmer_force_slave_reads = true
      expect(DbCharmer).to_not receive(:force_slave_reads?)
      expect(FooModel.db_charmer_force_slave_reads?).to be(true)
    end

    it "should use global settings when local setting is false" do
      FooModel.db_charmer_force_slave_reads = false

      expect(DbCharmer).to receive(:force_slave_reads?).and_return(true)
      expect(FooModel.db_charmer_force_slave_reads?).to be(true)

      expect(DbCharmer).to receive(:force_slave_reads?).and_return(false)
      expect(FooModel.db_charmer_force_slave_reads?).to be(false)
    end
  end
end
