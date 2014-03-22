require 'spec_helper'

describe Phare::Check::ScssLint do
  describe :should_run? do
    let(:check) { described_class.new('.') }
    before do
      expect(Phare).to receive(:system_output).with('which scss-lint').and_return(which_output)
      allow(Dir).to receive(:exists?).with(check.path).and_return(path_exists?)
    end

    context 'with found scss-lint command' do
      let(:which_output) { 'scss-lint' }
      let(:path_exists?) { true }
      it { expect(check).to be_able_to_run }
    end

    context 'with unfound scss-lint command' do
      let(:which_output) { '' }
      let(:path_exists?) { false }
      it { expect(check).to_not be_able_to_run }
    end
  end

  describe :run do
    let(:check) { described_class.new('.') }
    let(:run!) { check.run }

    context 'with available ScssLint' do
      before do
        expect(check).to receive(:should_run?).and_return(true)
        expect(Phare).to receive(:system).with(check.command)
        expect(Phare).to receive(:last_exit_status).and_return(scsslint_exit_status)
        expect(check).to receive(:print_banner)
      end

      context 'with check errors' do
        let(:scsslint_exit_status) { 0 }
        before { expect(Phare).to receive(:puts).with('No code style errors found.') }
        it { expect { run! }.to change { check.status }.to(0) }
      end

      context 'without check errors' do
        let(:scsslint_exit_status) { 1337 }
        before { expect(Phare).to receive(:puts).with('Something went wrong. Program exited with 1337') }
        it { expect { run! }.to change { check.status }.to(1337) }
      end
    end

    context 'with unavailable ScssLint' do
      before do
        expect(check).to receive(:should_run?).and_return(false)
        expect(Phare).to_not receive(:system).with(check.command)
        expect(check).to_not receive(:print_banner)
      end

      it { expect { run! }.to change { check.status }.to(0) }
    end
  end
end
