shared_examples_for 'Dml::Collection methods' do
  describe '#first' do
    context 'without arguments' do
      subject { instance.first }

      it 'returns first element' do
        expect(subject).to eql(john)
      end
    end

    context 'with arguments' do
      subject { instance.first(2) }

      it 'returns array' do
        expect(subject).to be_an(Array)
      end

      it 'has n elements' do
        expect(subject.length).to eql(2)
      end

      it 'returns first elements' do
        expect(subject).to contain_exactly(john, july)
      end
    end
  end

  describe '#last' do
    context 'without arguments' do
      subject { instance.last }

      it 'returns last element' do
        expect(subject).to eql(josh)
      end
    end

    context 'with arguments' do
      subject { instance.last(2) }

      it 'returns array' do
        expect(subject).to be_an(Array)
      end

      it 'has n elements' do
        expect(subject.length).to eql(2)
      end

      it 'returns last elements' do
        expect(subject).to contain_exactly(july, josh)
      end
    end
  end

  describe '#count' do
    it 'should count records' do
      expect(instance.count).to eql(3)
    end
  end

  describe '#sum' do
    it 'should count sum of field' do
      expect(instance.sum(:age)).to eql(66)
    end
  end

  describe '#avg' do
    it 'should calculate average for field' do
      expect(instance.avg(:age)).to eql(22)
    end
  end

  describe '#min' do
    it 'should calculate minimum value' do
      expect(instance.min(:age)).to eql(21)
    end
  end

  describe '#max' do
    it 'should calculate maximum value' do
      expect(instance.max(:age)).to eql(23)
    end
  end

  describe '#pluck' do
    context 'when one field' do
      it 'should take only given field' do
        expect(instance.pluck(:age)).to contain_exactly(21, 22, 23)
      end
    end

    context 'when n fields' do
      it 'should take only given fields' do
        expect(instance.pluck(:name, :age)).to contain_exactly(
          ['John', 21], ['July', 22], ['Josh', 23]
        )
      end
    end
  end

  describe '#length' do
    it 'should return members quantity' do
      expect(instance.length).to eql(3)
    end
  end
end
