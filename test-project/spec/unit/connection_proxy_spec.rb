RSpec.describe DbCharmer::ConnectionProxy do
  class ProxyTest
    def self.retrieve_connection(*args); raise 'Not implemented'; end
  end

  before :each do
    @conn = double('connection')
    @proxy = DbCharmer::ConnectionProxy.new(ProxyTest, :foo)
  end

  it "should retrieve connection from an underlying class" do
    expect(ProxyTest).to receive(:retrieve_connection).and_return(@conn)
    @proxy.inspect
  end

  it "should be a blankslate for the connection" do
    allow(ProxyTest).to receive(:retrieve_connection).and_return(@conn)
    expect(@proxy).to be(@conn)
  end

  it "should proxy methods with a block parameter" do
    module MockConnection
      def self.foo
        raise "No block given!" unless block_given?
        yield
      end
    end
    allow(ProxyTest).to receive(:retrieve_connection).and_return(MockConnection)
    res = @proxy.foo { :foo }
    expect(res).to eq(:foo)
  end

  it "should proxy all calls to the underlying class connections" do
    allow(ProxyTest).to receive(:retrieve_connection).and_return(@conn)
    expect(@conn).to receive(:foo)
    @proxy.foo
  end
end
