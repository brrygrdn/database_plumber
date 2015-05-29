RSpec.describe DatabasePlumber::LeakFinder do
  let(:normal_connection)   { double(:connection, adapter_name: 'NotSQLite') }
  let(:ignored_connection)  { double(:connection, adapter_name: 'SQLite'   ) }

  let(:happy_model)           { double(:happy,    abstract_class?: nil,  connection: normal_connection,  count: 0) }
  let(:leaky_model)           { double(:leaky,    abstract_class?: nil,  connection: normal_connection,  count: 1) }
  let(:abstract_model)        { double(:abstract, abstract_class?: true, connection: normal_connection,  count: 2) }
  let(:ignored_model)         { double(:ignored,  abstract_class?: nil,  connection: normal_connection,  count: 3) }
  let(:ignored_adapter_model) { double(:anon,     abstract_class?: nil,  connection: ignored_connection, count: 4) }

  let(:globally_ignored_models) { [ActiveRecord::SchemaMigration] }

  let(:model_space)     { [happy_model, leaky_model, ignored_model, abstract_model, ignored_adapter_model] | globally_ignored_models }

  before(:each) do
    model_space.each do |model|
      allow(model).to receive(:destroy_all)
    end
    allow(ActiveRecord::Base).to receive(:descendants) { model_space }
  end

  describe '.inspect' do
    context 'with no params' do
      let(:expected_leaks) do
        {
          leaky_model.to_s => 1,
          ignored_model.to_s => 3,
          ignored_adapter_model.to_s => 4
        }
      end

      before(:each) { @leaks = described_class.inspect }

      it { expect(@leaks).to eql(expected_leaks) }

      it { expect(ActiveRecord::SchemaMigration).not_to have_received(:destroy_all)}

      it { expect(happy_model).not_to have_received(:destroy_all) }
      it { expect(leaky_model).to have_received(:destroy_all) }

      it { expect(ignored_model).to have_received(:destroy_all) }
      it { expect(ignored_adapter_model).to have_received(:destroy_all) }
    end

    context 'with an ignored model' do
      let(:options_params) do
        {
          ignored_models: [ignored_model]
        }
      end

      let(:expected_leaks) do
        {
          leaky_model.to_s => 1,
          ignored_adapter_model.to_s => 4
        }
      end

      before(:each) { @leaks = described_class.inspect(options_params) }

      it { expect(@leaks).to eql(expected_leaks) }

      it { expect(ActiveRecord::SchemaMigration).not_to have_received(:destroy_all)}

      it { expect(happy_model).not_to have_received(:destroy_all) }
      it { expect(leaky_model).to have_received(:destroy_all) }

      it { expect(ignored_model).not_to have_received(:destroy_all) }
      it { expect(ignored_adapter_model).to have_received(:destroy_all) }
    end

    context 'with an ignored adapter' do
      let(:options_params) do
        {
          ignored_adapters: [:sqlite]
        }
      end

      let(:expected_leaks) do
        {
          leaky_model.to_s => 1,
          ignored_model.to_s => 3
        }
      end

      before(:each) { @leaks = described_class.inspect(options_params) }

      it { expect(@leaks).to eql(expected_leaks) }

      it { expect(ActiveRecord::SchemaMigration).not_to have_received(:destroy_all)}

      it { expect(happy_model).not_to have_received(:destroy_all) }
      it { expect(leaky_model).to have_received(:destroy_all) }

      it { expect(ignored_model).to have_received(:destroy_all) }
      it { expect(ignored_adapter_model).not_to have_received(:destroy_all) }
    end

    context 'with no leaking models in scope' do
      let(:options_params) do
        {
          ignored_models: [ignored_model, leaky_model],
          ignored_adapters: [:sqlite]
        }
      end

      before(:each) { @leaks = described_class.inspect(options_params) }

      it { expect(@leaks).to be_empty }

      it { expect(ActiveRecord::SchemaMigration).not_to have_received(:destroy_all)}

      it { expect(happy_model).not_to have_received(:destroy_all) }
      it { expect(leaky_model).not_to have_received(:destroy_all) }

      it { expect(ignored_model).not_to have_received(:destroy_all) }
      it { expect(ignored_adapter_model).not_to have_received(:destroy_all) }
    end
  end
end
