RSpec.describe "ActiveRecord slave-enabled models" do
  before :each do
    class User < ActiveRecord::Base
      db_magic connection: :user_master, slave: :slave01
    end
  end

  describe "in finder method" do
    [ :last, :first, :all ].each do |meth|
      describe meth do
        it "should go to the slave if called on the first level connection" do
          expect(User.on_slave.connection).to receive(:select_all).and_return([])
          User.send(meth)
        end

        it "should not change connection if called in an on_db block" do
          stub_columns_for_rails31 User.on_db(:logs).connection
          expect(User.on_db(:logs).connection).to receive(:select_all).and_return([])
          expect(User.on_slave.connection).to_not receive(:select_all)
          User.on_db(:logs).send(meth)
        end

        it "should not change connection when it's already been changed by on_slave call" do
          pending "rails3: not sure if we need this spec" if DbCharmer.rails3?
          User.on_slave do
            expect(User.on_slave.connection).to receive(:select_all).and_return([])
            expect(User).to_not receive(:on_db)
            User.send(meth)
          end
        end

        it "should not change connection if called in a transaction" do
          expect(User.on_db(:user_master).connection).to receive(:select_all).and_return([])
          expect(User.on_slave.connection).to_not receive(:select_all)
          User.transaction { User.send(meth) }
        end
      end
    end

    it "should go to the master if called find with lock: true option" do
      expect(User.on_db(:user_master).connection).to receive(:select_all).and_return([])
      expect(User.on_slave.connection).to_not receive(:select_all)
      User.lock.first
    end

    it "should not go to the master if no lock: true option passed" do
      expect(User.on_db(:user_master).connection).to_not receive(:select_all)
      expect(User.on_slave.connection).to receive(:select_all).and_return([])
      User.first
    end

    it "should correctly pass all find params to the underlying code" do
      User.delete_all
      u1 = User.create(login: 'foo')
      u2 = User.create(login: 'bar')

      expect(User.where(login: 'foo').all).to eq([ u1 ])
      expect(User.limit(1).all.size).to eq(1)
      expect(User.where(login: 'bar').first).to eq(u2)
    end
  end

  describe "in calculation method" do
    [ :count, :minimum, :maximum, :average ].each do |meth|
      describe meth do
        it "should go to the slave if called on the first level connection" do
          expect(User.on_slave.connection).to receive(:select_value).and_return(1)
          expect(User.send(meth, :id)).to eq(1)
        end

        it "should not change connection if called in an on_db block" do
          expect(User.on_db(:logs).connection).to receive(:select_value).and_return(1)
          expect(User.on_slave.connection).to_not receive(:select_value)
          expect(User.on_db(:logs).send(meth, :id)).to eq(1)
        end

        it "should not change connection when it's already been changed by an on_slave call" do
          pending "rails3: not sure if we need this spec" if DbCharmer.rails3?
          User.on_slave do
            expect(User.on_slave.connection).to receive(:select_value).and_return(1)
            expect(User).to_not receive(:on_db)
            expect(User.send(meth, :id)).to eq(1)
          end
        end

        it "should not change connection if called in a transaction" do
          expect(User.on_db(:user_master).connection).to receive(:select_value).and_return(1)
          expect(User.on_slave.connection).to_not receive(:select_value)
          expect(User.transaction { User.send(meth, :id) }).to eq(1)
        end
      end
    end
  end

  describe "in pluck method" do
    class TestMysqlResult < Array
      def columns
        self.first.keys
      end
    end

    before :each do
      @mysql_result = TestMysqlResult.new([{'col1' => 1}, {'col1' => 2}])
    end

    it "should go to the slave if called on the first level connection" do
      expect(User.on_slave.connection).to receive(:exec_query).and_return(@mysql_result)
      expect(User.pluck(:id)).to eq([1, 2])
    end

    it "should not change connection if called in an on_db block" do
      expect(User.on_db(:logs).connection).to receive(:exec_query).and_return(@mysql_result)
      expect(User.on_slave.connection).to_not receive(:exec_query)
      expect(User.on_db(:logs).pluck(:id)).to eq([1, 2])
    end

    it "should not change connection if called in a transaction" do
      expect(User.on_db(:user_master).connection).to receive(:exec_query).and_return(@mysql_result)
      expect(User.on_slave.connection).to_not receive(:exec_query)
      expect(User.transaction { User.pluck(:id) }).to eq([1, 2])
    end
  end

  describe "in data manipulation methods" do
    it "should go to the master by default" do
      expect(User.on_db(:user_master).connection).to receive(:delete)
      User.delete_all
    end

    it "should go to the master even in slave-enabling chain calls" do
      expect(User.on_db(:user_master).connection).to receive(:delete)
      User.on_slave.delete_all
    end

    it "should go to the master even in slave-enabling block calls" do
      expect(User.on_db(:user_master).connection).to receive(:delete)
      User.on_slave { |u| u.delete_all }
    end
  end

  describe "in instance method" do
    describe "reload" do
      it "should always be done on the master" do
        User.delete_all
        u = User.create

        expect(User.on_db(:user_master).connection).to receive(:select_all).and_return([{}])
        expect(User.on_slave.connection).to_not receive(:select_all)

        User.on_slave { u.reload }
      end
    end
  end
end
