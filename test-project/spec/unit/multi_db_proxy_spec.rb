RSpec.describe "ActiveRecord model with db_magic" do
  before :each do
    class Blah < ActiveRecord::Base
      self.table_name = :posts
      db_magic connection: nil
    end
  end

  describe "(instance)" do
    before :each do
      @blah = Blah.new
    end

    describe "in on_db method" do
      describe "with a block" do
        it "should switch connection to specified one and yield the block" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          @blah.on_db(:logs) do
            expect(Blah.db_charmer_connection_proxy).to_not be_nil
          end
        end

        it "should switch connection back after the block finished its work" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          @blah.on_db(:logs) {}
          expect(Blah.db_charmer_connection_proxy).to be_nil
        end

        it "should manage connection level values" do
          expect(Blah.db_charmer_connection_level).to eq(0)
          @blah.on_db(:logs) do |m|
            expect(m.class.db_charmer_connection_level).to eq(1)
          end
          expect(Blah.db_charmer_connection_level).to eq(0)
        end
      end

      describe "as a chain call" do
        it "should switch connection for all chained calls" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          expect(@blah.on_db(:logs)).to_not be_nil
        end

        it "should switch connection for non-chained calls" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          @blah.on_db(:logs).to_s
          expect(Blah.db_charmer_connection_proxy).to be_nil
        end

        it "should restore connection" do
          User.first
          expect(User.connection.object_id).to eq(User.on_master.connection.object_id)

          User.on_db(:slave01).first
          expect(User.connection.object_id).to eq(User.on_master.connection.object_id)
        end

        it "should restore connection after error" do
          pending "Disabled in RSpec prior to version 2 because of lack of .any_instance support" unless Object.respond_to?(:any_instance)

          User.on_db(:slave01).first
          User.first
          ActiveRecord::Base.connection_handler.clear_all_connections!
          allow_any_instance_of(ActiveRecord::ConnectionAdapters::MysqlAdapter).to receive(:connect) { raise Mysql::Error, 'Connection error' }
          expect { User.on_db(:slave01).first }.to raise_error(Mysql::Error)
          ActiveRecord::ConnectionAdapters::MysqlAdapter.any_instance.unstub(:connect)
          expect(User.connection.connection_name).to eq(User.on_master.connection.connection_name)
        end
      end
    end
  end

  describe "(class)" do
    describe "in on_db method" do
      describe "with a block" do
        it "should switch connection to specified one and yield the block" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          Blah.on_db(:logs) do
            expect(Blah.db_charmer_connection_proxy).to_not be_nil
          end
        end

        it "should switch connection back after the block finished its work" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          Blah.on_db(:logs) {}
          expect(Blah.db_charmer_connection_proxy).to be_nil
        end

        it "should manage connection level values" do
          expect(Blah.db_charmer_connection_level).to eq(0)
          Blah.on_db(:logs) do |m|
            expect(m.db_charmer_connection_level).to eq(1)
          end
          expect(Blah.db_charmer_connection_level).to eq(0)
        end
      end

      describe "as a chain call" do
        it "should switch connection for all chained calls" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          expect(Blah.on_db(:logs)).to_not be_nil
        end

        it "should switch connection for non-chained calls" do
          expect(Blah.db_charmer_connection_proxy).to be_nil
          Blah.on_db(:logs).to_s
          expect(Blah.db_charmer_connection_proxy).to be_nil
        end
      end
    end

    describe "in on_slave method" do
      before :each do
        Blah.db_magic slaves: [ :slave01 ]
      end

      it "should use one tof the model's slaves if no slave given" do
        expect(Blah.on_slave.db_charmer_connection_proxy.object_id).to eq(Blah.coerce_to_connection_proxy(:slave01).object_id)
      end

      it "should use given slave" do
        expect(Blah.on_slave(:logs).db_charmer_connection_proxy.object_id).to eq(Blah.coerce_to_connection_proxy(:logs).object_id)
      end

      it 'should support block calls' do
        Blah.on_slave do |m|
          expect(m.db_charmer_connection_proxy.object_id).to eq(Blah.coerce_to_connection_proxy(:slave01).object_id)
        end
      end
    end

    describe "in on_master method" do
      before :each do
        Blah.db_magic slaves: [ :slave01 ]
      end

      it "should run queries on the master" do
        expect(Blah.on_master.db_charmer_connection_proxy).to be_nil
      end
    end
  end
end
