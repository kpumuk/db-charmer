class FooModelForConnSwitching < ActiveRecord::Base; end
class BarModelForConnSwitching < ActiveRecord::Base; end

RSpec.describe DbCharmer, "AR connection switching" do
  describe "in switch_connection_to method" do
    before :all do
      BarModelForConnSwitching.hijack_connection!
    end

    before :each do
      @proxy = double('proxy')
      allow(@proxy).to receive(:db_charmer_connection_name).and_return(:myproxy)
    end

    before :each do
      BarModelForConnSwitching.db_charmer_connection_proxy = @proxy
      expect(BarModelForConnSwitching.connection).to be(@proxy)
    end

    it "should accept nil and reset connection to default" do
      BarModelForConnSwitching.switch_connection_to(nil)
      expect(BarModelForConnSwitching.connection).to be(ActiveRecord::Base.connection)
    end

    it "should accept a string and generate an abstract class with connection factory" do
      BarModelForConnSwitching.switch_connection_to('logs')
      BarModelForConnSwitching.connection.object_id == DbCharmer::ConnectionFactory.connect('logs').object_id
    end

    it "should accept a symbol and generate an abstract class with connection factory" do
      BarModelForConnSwitching.switch_connection_to(:logs)
      expect(BarModelForConnSwitching.connection.object_id).to eq(DbCharmer::ConnectionFactory.connect('logs').object_id)
    end

    it "should accept a model and use its connection proxy value" do
      FooModelForConnSwitching.switch_connection_to(:logs)
      BarModelForConnSwitching.switch_connection_to(FooModelForConnSwitching)
      expect(BarModelForConnSwitching.connection.object_id).to eq(DbCharmer::ConnectionFactory.connect('logs').object_id)
    end

    context "with a hash parameter" do
      before :each do
        @conf = {
          adapter:         'mysql2',
          username:        'db_charmer_ro',
          database:        'db_charmer_sandbox_test',
          connection_name: 'sanbox_ro',
        }
      end

      it "should fail if there is no :connection_name parameter" do
        @conf.delete(:connection_name)
        expect(lambda { BarModelForConnSwitching.switch_connection_to(@conf) }).to raise_error(ArgumentError)
      end

      it "generate an abstract class with connection factory" do
        BarModelForConnSwitching.switch_connection_to(@conf)
        expect(BarModelForConnSwitching.connection.object_id).to eq(DbCharmer::ConnectionFactory.connect_to_db(@conf[:connection_name], @conf).object_id)
      end
    end

    it "should support connection switching for AR::Base" do
      ActiveRecord::Base.switch_connection_to(:logs)
      ActiveRecord::Base.connection.object_id == DbCharmer::ConnectionFactory.connect('logs').object_id
      ActiveRecord::Base.switch_connection_to(nil)
    end
  end
end

RSpec.describe DbCharmer, "for ActiveRecord models" do
  describe "in establish_real_connection_if_exists method" do
    it "should check connection name if requested" do
      expect(lambda { FooModelForConnSwitching.establish_real_connection_if_exists(:foo, true) }).to raise_error(ArgumentError)
    end

    it "should not check connection name if not reqested" do
      expect(lambda { FooModelForConnSwitching.establish_real_connection_if_exists(:foo) }).to_not raise_error
    end

    it "should not check connection name if reqested not to" do
      expect(lambda { FooModelForConnSwitching.establish_real_connection_if_exists(:foo, false) }).to_not raise_error
    end

    it "should establish connection when connection configuration exists" do
      expect(FooModelForConnSwitching).to receive(:establish_connection)
      FooModelForConnSwitching.establish_real_connection_if_exists(:logs)
    end

    it "should not establish connection even when connection configuration does not exist" do
      expect(FooModelForConnSwitching).to_not receive(:establish_connection)
      FooModelForConnSwitching.establish_real_connection_if_exists(:blah)
    end
  end
end
