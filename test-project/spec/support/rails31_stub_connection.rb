def stub_columns_for_rails31(connection)
  allow(connection.abstract_connection_class.retrieve_connection).to receive(:columns).and_return([])
end
