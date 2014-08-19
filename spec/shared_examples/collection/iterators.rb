shared_examples_for 'Dml::Collection::Members iterators' do
  describe '#each' do
    it 'should iterate over objects' do
      names = []
      instance.each { |m| names << m[:name] }

      expect(names).to contain_exactly('John', 'July', 'Josh')
    end
  end

  describe '#map' do
    it 'should map objects' do
      names = instance.map { |m| m[:name] }

      expect(names).to contain_exactly('John', 'July', 'Josh')
    end
  end

  describe '#all' do
    subject { instance.all }

    it 'should return all records' do
      expect(subject.map { |m| m[:name] }).to contain_exactly('John', 'July', 'Josh')
    end
  end
end

shared_examples_for 'Dml::Collection iterators' do
  describe '#each' do
    it 'wraps in entities' do
      instance.each do |ent|
        expect(ent).to be_an(entity)
      end
    end

    it 'should wrap and iterate over objects' do
      names = []
      instance.each { |m| names << m.name }

      expect(names).to contain_exactly('John', 'July', 'Josh')
    end
  end

  describe '#map' do
    it 'should wrap and map objects' do
      names = instance.map { |m| m.name }

      expect(names).to contain_exactly('John', 'July', 'Josh')
    end
  end

  describe '#all' do
    subject { instance.all }

    it 'should return wrapped records' do
      expect(subject.map { |m| m.name }).to contain_exactly('John', 'July', 'Josh')
    end
  end
end
