# frozen_string_literal: true

RSpec.describe Packs do
  describe '.all' do
    context 'in app with a simple package' do
      before do
        write_pack('packs/my_pack')
      end

      it { expect(Packs.all.count).to eq 1 }
    end

    context 'in an app with nested packs' do
      before do
        write_pack('packs/my_pack')
        write_pack('packs/my_pack/subpack')
      end

      it { expect(Packs.all.count).to eq 2 }
    end

    context 'in an app with a differently configured root' do
      before do
        write_pack('packs/my_pack')
        write_pack('components/my_pack')
        write_file('packs.yml', <<~YML)
          pack_paths:
            - packs/*
            - components/*
        YML
      end

      it { expect(Packs.all.count).to eq 2 }
    end

    context 'in an app with a differently configured root configured via ruby' do
      before do
        write_pack('packs/my_pack')
        write_pack('components/my_pack')
        Packs.configure do |config|
          config.pack_paths = ['packs/*', 'components/*']
        end
      end

      it { expect(Packs.all.count).to eq 2 }
    end

    context 'in an app with a differently configured root configured via ruby and YML' do
      before do
        write_pack('packs/my_pack')
        write_pack('components/my_pack')
        write_pack('packages/my_pack')
        write_file('packs.yml', <<~YML)
          pack_paths:
            - packs/*
            - components/*
        YML
        Packs.configure do |config|
          config.pack_paths = ['packs/*']
        end
      end

      it 'prioritizes the YML configuration' do
        expect(Packs.all.count).to eq 2
      end
    end
  end

  describe '.find' do
    context 'in app with a simple package' do
      before do
        write_pack('packs/my_pack')
      end

      it { expect(Packs.find('packs/my_pack').name).to eq 'packs/my_pack' }
    end

    context 'in an app with nested packs' do
      before do
        write_pack('packs/my_pack')
        write_pack('packs/my_pack/subpack')
      end

      it { expect(Packs.find('packs/my_pack').name).to eq 'packs/my_pack' }
      it { expect(Packs.find('packs/my_pack/subpack').name).to eq 'packs/my_pack/subpack' }
    end

    context 'in an app with a differently configured root' do
      before do
        write_pack('packs/my_pack')
        write_pack('components/my_pack')
        write_file('packs.yml', <<~YML)
          pack_paths:
            - packs/*
            - components/*
        YML
      end

      it { expect(Packs.find('packs/my_pack').name).to eq 'packs/my_pack' }
      it { expect(Packs.find('components/my_pack').name).to eq 'components/my_pack' }
    end
  end

  describe '.for_file' do
    before do
      write_pack('packs/package_1')
      write_pack('packs/package_1_new')
    end

    context 'given a filepath in pack_1' do
      let(:filepath) { 'packs/package_1/path/to/file.rb' }
      it { expect(Packs.for_file(filepath).name).to eq 'packs/package_1' }
    end

    context 'given a file path in pack_1_new' do
      let(:filepath) { 'packs/package_1_new/path/to/file.rb' }
      it { expect(Packs.for_file(filepath).name).to eq 'packs/package_1_new' }
    end

    context 'given a file path that is exactly the root of a pack' do
      let(:filepath) { 'packs/package_1' }
      it { expect(Packs.for_file(filepath).name).to eq 'packs/package_1' }
    end

    context 'given a file path not in a pack' do
      let(:filepath) { 'path/to/file.rb' }
      it { expect(Packs.for_file(filepath)).to eq nil }
    end

    context 'in an app with nested packs' do
      before do
        write_pack('packs/my_pack')
        write_file('packs/my_pack/file.rb')
        write_pack('packs/my_pack/subpack')
        write_file('packs/my_pack/subpack/file.rb')
      end

      it 'distinguishes between files in nested packs and parent packs' do
        expect(Packs.for_file('packs/my_pack/subpack/file.rb').name).to eq 'packs/my_pack/subpack'
        expect(Packs.for_file('packs/my_pack/file.rb').name).to eq 'packs/my_pack'
      end
    end
  end
end
