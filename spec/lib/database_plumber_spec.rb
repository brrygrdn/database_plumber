RSpec.describe DatabasePlumber do
  let(:report_class) { DatabasePlumber::Report }

  let(:current_example) { self }

  before(:each) do
    allow(report_class).to receive(:on)
    described_class.log current_example
  end

  context 'with no leaks' do
    before(:each) do
      described_class.inspect
    end

    it { expect(report_class).not_to have_received(:on) }
  end

  context 'with leaks' do
    let(:leaks) do
      { 'Foo' => 5 }
    end

    before(:each) do
      allow(DatabasePlumber::LeakFinder).to receive(:inspect) { leaks }
      described_class.inspect
    end

    it { expect(report_class).to have_received(:on).with(current_example, leaks) }
  end
end
