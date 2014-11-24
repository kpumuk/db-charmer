RSpec.describe DbCharmer::ConnectionFactory do
  context "in generate_abstract_class method" do
    it "should fail if requested connection config does not exists" do
      expect { DbCharmer::ConnectionFactory.generate_abstract_class('foo') }.to raise_error(ArgumentError)
    end

    it "should not fail if requested connection config does not exists and should_exist = false" do
      expect { DbCharmer::ConnectionFactory.generate_abstract_class('foo', false) }.to_not raise_error
    end

    it "should fail if requested connection config does not exists and should_exist = true" do
      expect { DbCharmer::ConnectionFactory.generate_abstract_class('foo', true) }.to raise_error(ArgumentError)
    end

    it "should generate abstract connection classes" do
      klass = DbCharmer::ConnectionFactory.generate_abstract_class('foo', false)
      expect(klass.superclass).to be(ActiveRecord::Base)
    end

    it "should work with weird connection names" do
      klass = DbCharmer::ConnectionFactory.generate_abstract_class('foo.bar@baz#blah', false)
      expect(klass.superclass).to be(ActiveRecord::Base)
    end
  end

  context "in generate_empty_abstract_ar_class method" do
    it "should generate an abstract connection class" do
      klass = DbCharmer::ConnectionFactory.generate_empty_abstract_ar_class('::MyFooAbstractClass')
      expect(klass.superclass).to be(ActiveRecord::Base)
    end
  end

  context "in establish_connection method" do
    it "should generate an abstract class" do
      klass = double('AbstractClass')
      conn = double('connection1')
      allow(klass).to receive(:retrieve_connection).and_return(conn)
      expect(DbCharmer::ConnectionFactory).to receive(:generate_abstract_class).and_return(klass)
      expect(DbCharmer::ConnectionFactory.establish_connection(:foo)).to be(conn)
    end

    it "should create and return a connection proxy for the abstract class" do
      klass = double('AbstractClass')
      expect(DbCharmer::ConnectionFactory).to receive(:generate_abstract_class).and_return(klass)
      expect(DbCharmer::ConnectionProxy).to receive(:new).with(klass, :foo)
      DbCharmer::ConnectionFactory.establish_connection(:foo)
    end
  end

  context "in establish_connection_to_db method" do
    it "should generate an abstract class" do
      klass = double('AbstractClass')
      conn =  double('connection2')
      allow(klass).to receive(:establish_connection)
      allow(klass).to receive(:retrieve_connection).and_return(conn)
      expect(DbCharmer::ConnectionFactory).to receive(:generate_empty_abstract_ar_class).and_return(klass)
      expect(DbCharmer::ConnectionFactory.establish_connection_to_db(:foo, username: :foo)).to be(conn)
    end

    it "should create and return a connection proxy for the abstract class" do
      klass = double('AbstractClass')
      allow(klass).to receive(:establish_connection)
      expect(DbCharmer::ConnectionFactory).to receive(:generate_empty_abstract_ar_class).and_return(klass)
      expect(DbCharmer::ConnectionProxy).to receive(:new).with(klass, :foo)
      DbCharmer::ConnectionFactory.establish_connection_to_db(:foo, username: :foo)
    end
  end

  context "in connect method" do
    before :each do
      DbCharmer::ConnectionFactory.reset!
    end

    it "should return a connection proxy" do
      expect(DbCharmer::ConnectionFactory.connect(:logs)).to be_kind_of(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    end

# should_receive is evil on a singletone classes
#    it "should memoize proxies" do
#      conn = double('connection3')
#      DbCharmer::ConnectionFactory.should_receive(:establish_connection).with('foo', false).once.and_return(conn)
#      DbCharmer::ConnectionFactory.connect(:foo)
#      DbCharmer::ConnectionFactory.connect(:foo)
#    end
  end

  context "in connect_to_db method" do
    before :each do
      DbCharmer::ConnectionFactory.reset!
      @conf = {
        adapter:         'mysql2',
        username:        'db_charmer_ro',
        database:        'db_charmer_sandbox_test',
        connection_name: 'sanbox_ro',
      }
    end

    it "should return a connection proxy" do
      expect(DbCharmer::ConnectionFactory.connect_to_db(@conf[:connection_name], @conf)).to be_kind_of(ActiveRecord::ConnectionAdapters::AbstractAdapter)
    end

# should_receive is evil on a singletone classes
#    it "should memoize proxies" do
#      conn = double('connection4')
#      DbCharmer::ConnectionFactory.should_receive(:establish_connection_to_db).with(@conf[:connection_name], @conf).once.and_return(conn)
#      DbCharmer::ConnectionFactory.connect_to_db(@conf[:connection_name], @conf)
#      DbCharmer::ConnectionFactory.connect_to_db(@conf[:connection_name], @conf)
#    end
  end

end
