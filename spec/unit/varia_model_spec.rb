require 'spec_helper'

describe VariaModel do
  describe "ClassMethods" do
    subject do
      Class.new do
        include VariaModel
      end
    end

    describe "::attributes" do
      it "returns a VariaModel::Attributes" do
        expect(subject.attributes).to be_a(described_class::Attributes)
      end

      it "is empty by default" do
        expect(subject.attributes).to be_empty
      end
    end

    describe "::attribute" do
      it "adds an attribute to the attributes hash for each attribute function call" do
        subject.attribute 'jamie.winsor'
        subject.attribute 'brooke.winsor'

        expect(subject.attributes).to have(2).items
      end

      it "adds a validation if :required option is true" do
        subject.attribute 'brooke.winsor', required: true

        expect(subject.validations).to have(1).item
      end

      it "adds a validation if the :type option is provided" do
        subject.attribute 'brooke.winsor', type: :string

        expect(subject.validations).to have(1).item
      end

      it "sets a default value if :default option is provided" do
        subject.attribute 'brooke.winsor', default: 'rhode island'

        expect(subject.attributes.dig('brooke.winsor')).to eql('rhode island')
      end

      it "allows an attribute called 'attributes'" do
        subject.attribute 'attributes', default: 'bag of junk'

        expect(subject.attributes.dig('attributes')).to eql('bag of junk')
      end

      it "allows an attribute called 'attribute'" do
        subject.attribute 'attribute', default: 'some value'

        expect(subject.attributes.dig('attribute')).to eql('some value')
      end

      it "allows an attribute that has a lambda default value" do
        subject.attribute 'brooke', default: ->{ "winsor".upcase }

        expect(subject.attributes.dig('brooke')).to be_a(Proc)
      end
    end

    describe "::validations" do
      it "returns a Hashie::Mash" do
        expect(subject.validations).to be_a(Hashie::Mash)
      end

      it "is empty by default" do
        expect(subject.validations).to be_empty
      end
    end

    describe "::validations_for" do
      context "when an attribute is registered and has validations" do
        before(:each) do
          subject.attribute("nested.attribute", required: true, type: String)
        end

        it "returns an array of procs" do
          validations = subject.validations_for("nested.attribute")

          expect(validations).to be_a(Array)
          expect(validations).to each be_a(Proc)
        end
      end

      context "when an attribute is registered but has no validations" do
        before(:each) do
          subject.attribute("nested.attribute")
        end

        it "returns an empty array" do
          validations = subject.validations_for("nested.attribute")

          expect(validations).to be_a(Array)
          expect(validations).to be_empty
        end
      end

      context "when an attribute is not registered" do
        it "returns an empty array" do
          validations = subject.validations_for("not_existing.attribute")

          expect(validations).to be_a(Array)
          expect(validations).to be_empty
        end
      end

      describe "#assignment_mode" do
        it "returns the default assignment mode :whitelist" do
          expect(subject.assignment_mode).to eql(:whitelist)
        end
      end

      describe "#set_assignment_mode" do
        it "sets the assignment_mode to whitelist" do
          subject.set_assignment_mode(:whitelist)

          expect(subject.assignment_mode).to eql(:whitelist)
        end

        it "sets the assignment_mode to carefree" do
          subject.set_assignment_mode(:carefree)

          expect(subject.assignment_mode).to eql(:carefree)
        end

        it "raises if given an invalid assignment mode" do
          expect { subject.set_assignment_mode(:not_a_real_mode) }.to raise_error(ArgumentError)
        end
      end
    end

    describe "::validate_kind_of" do
      let(:types) { [ String, Buff::Boolean ] }
      let(:key) { 'nested.one' }

      subject do
        Class.new do
          include VariaModel

          attribute 'nested.one', types: [String, Buff::Boolean]
        end
      end

      let(:model) { subject.new }

      it "returns an array" do
        expect(subject.validate_kind_of(types, model, key)).to be_a(Array)
      end

      context "failure" do
        before(:each) { model.nested.one = nil }

        it "returns an array where the first element is ':error'" do
          expect(subject.validate_kind_of(types, model, key).first).to eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute and types" do
          types.each do |type|
            expect(subject.validate_kind_of(types, model, key)[1]).to match(/#{type}/)
          end
          expect(subject.validate_kind_of(types, model, key)[1]).to match(/#{key}/)
        end
      end

      context "success" do
        before(:each) { model.nested.one = true }

        it "returns an array where the first element is ':ok'" do
          expect(subject.validate_kind_of(types, model, key).first).to eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          expect(subject.validate_kind_of(types, model, key)[1]).to be_blank
        end
      end

      context "when given two types of the same kind" do
        let(:types) { [ String, String ] }
        let(:key) { 'nested.one' }

        subject do
          Class.new do
            include VariaModel

            attribute 'nested.one', types: [String, Buff::Boolean]
          end
        end

        let(:model) { subject.new }
        before(:each) { model.nested.one = nil }

        it "returns a error message that contains the type error only once" do
          error_message = "Expected attribute: 'nested.one' to be a type of: 'String'"
          expect(subject.validate_kind_of(types, model, key)[1]).to eql(error_message)
        end
      end
    end

    describe "::validate_required" do
      subject do
        Class.new do
          include VariaModel

          attribute 'nested.one', required: true
        end
      end

      let(:key) { 'nested.one' }
      let(:model) { subject.new }

      it "returns an array" do
        expect(subject.validate_required(model, key)).to be_a(Array)
      end

      it "fails validation if the value of the attribute is nil" do
        model.set_attribute(key, nil)

        expect(subject.validate_required(model, key).first).to eql(:error)
      end

      it "passes validation if the value of the attribute is false" do
        model.set_attribute(key, false)

        expect(subject.validate_required(model, key).first).to eql(:ok)
      end

      it "passes validation if the value of the attribute is not nil" do
        model.set_attribute(key, 'some_value')

        expect(subject.validate_required(model, key).first).to eql(:ok)
      end

      context "failure" do
        before(:each) { model.nested.one = nil }

        it "returns an array where the first element is ':error'" do
          expect(subject.validate_required(model, key).first).to eql(:error)
        end

        it "returns an array where the second element is an error message containing the attribute name" do
          expect(subject.validate_required(model, key)[1]).to match(/#{key}/)
        end
      end

      context "success" do
        before(:each) { model.nested.one = "hello" }

        it "returns an array where the first element is ':ok'" do
          expect(subject.validate_required(model, key).first).to eql(:ok)
        end

        it "returns an array where the second element is a blank string" do
          expect(subject.validate_required(model, key)[1]).to be_blank
        end
      end
    end
  end

  subject do
    Class.new do
      include VariaModel

      attribute 'nested.not_coerced', default: 'hello'
      attribute 'nested.no_default'
      attribute 'nested.coerced', coerce: lambda { |m| m.to_s }
      attribute 'toplevel', default: 'hello'
      attribute 'no_default'
      attribute 'coerced', coerce: lambda { |m| m.to_s }
    end.new
  end

  describe "GeneratedAccessors" do
    describe "nested getter" do
      it "returns the default value" do
        expect(subject.nested.not_coerced).to eql('hello')
      end

      it "returns nil if there is no default value" do
        expect(subject.nested.no_default).to be_nil
      end
    end

    describe "toplevel getter" do
      it "returns the default value" do
        expect(subject.toplevel).to eql('hello')
      end

      it "returns nil if there is no default value" do
        expect(subject.no_default).to be_nil
      end
    end

    describe "nested setter" do
      it "sets the value of the nested attribute" do
        subject.nested.not_coerced = 'world'

        expect(subject.nested.not_coerced).to eql('world')
      end
    end

    describe "toplevel setter" do
      it "sets the value of the top level attribute" do
        subject.toplevel = 'world'

        expect(subject.toplevel).to eql('world')
      end
    end

    describe "nested coerced setter" do
      it "sets the value of the nested coerced attribute" do
        subject.nested.coerced = 1

        expect(subject.nested.coerced).to eql("1")
      end
    end

    describe "toplevel coerced setter" do
      it "sets the value of the top level coerced attribute" do
        subject.coerced = 1

        expect(subject.coerced).to eql('1')
      end
    end

    context "given two nested attributes with a common parent and default values" do
      subject do
        Class.new do
          include VariaModel

          attribute 'nested.one', default: 'val_one'
          attribute 'nested.two', default: 'val_two'
        end.new
      end

      it "sets a default value for each nested attribute" do
        expect(subject.nested.one).to eql('val_one')
        expect(subject.nested.two).to eql('val_two')
      end
    end

    context "given two nested attributes with a common parent and coercions" do
      subject do
        Class.new do
          include VariaModel

          attribute 'nested.one', coerce: lambda { |m| m.to_s }
          attribute 'nested.two', coerce: lambda { |m| m.to_s }
        end.new
      end

      it "coerces each value if both have a coercion" do
        subject.nested.one = 1
        subject.nested.two = 2

        expect(subject.nested.one).to eql("1")
        expect(subject.nested.two).to eql("2")
      end
    end

    context "given an attribute called 'attributes'" do
      subject do
        Class.new do
          include VariaModel

          attribute 'attributes', default: Hash.new
        end.new
      end

      it "allows the setting and getting of the 'attributes' mimic methods" do
        expect(subject.attributes).to be_a(Hash)
        expect(subject.attributes).to be_empty

        new_hash = { something: "here" }
        subject.attributes = new_hash
        expect(subject.attributes[:something]).to eql("here")
      end
    end
  end

  describe "Validations" do
    describe "validate required" do
      subject do
        Class.new do
          include VariaModel

          attribute 'brooke.winsor', required: true
        end.new
      end

      it "is not valid if it fails validation" do
        expect(subject).not_to be_valid
      end

      it "adds an error for each attribute that fails validations" do
        subject.validate

        expect(subject.errors).to have(1).item
      end

      it "adds a message for each failed validation" do
        subject.validate

        expect(subject.errors['brooke.winsor']).to have(1).item
        expect(subject.errors['brooke.winsor'][0]).to eql("A value is required for attribute: 'brooke.winsor'")
      end
    end

    describe "validate type" do
      subject do
        Class.new do
          include VariaModel

          attribute 'brooke.winsor', type: String
        end.new
      end

      before(:each) { subject.brooke.winsor = false }

      it "returns false if it fails validation" do
        expect(subject).not_to be_valid
      end

      it "adds an error if it fails validation" do
        subject.validate

        expect(subject.errors).to have(1).item
        expect(subject.errors['brooke.winsor']).to have(1).item
        expect(subject.errors['brooke.winsor'][0]).to eql("Expected attribute: 'brooke.winsor' to be a type of: 'String', 'NilClass'")
      end
    end
  end

  describe "#set_attribute" do
    subject do
      Class.new do
        include VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
        attribute 'brooke.costantini', type: String, default: 'sister'
      end.new
    end

    it "sets the value of the given attribute" do
      subject.set_attribute('brooke.winsor', 'rhode island')

      expect(subject.brooke.winsor).to eql('rhode island')
    end

    it "does not disturb the other attributes" do
      subject.set_attribute('brooke.winsor', 'rhode island')

      expect(subject.brooke.costantini).to eql('sister')
    end
  end

  describe "#get_attribute" do
    subject do
      Class.new do
        include VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
      end.new
    end

    it "returns the value of the given dotted path" do
      expect(subject.get_attribute('brooke.winsor')).to eql('sister')
    end

    it "returns nil if the dotted path matches no attributes" do
      expect(subject.get_attribute('brooke.costantini')).to be_nil
    end

    it "returns the current value of the Proc" do
      subject.brooke.winsor = ->{ "bacon".upcase }
      expect(subject.get_attribute("brooke.winsor")).to eql("BACON")
    end

    it "returns the current value of the Proc each time" do
      @magic = "ponies"
      subject.brooke.winsor = -> { @magic }
      expect(subject.get_attribute("brooke.winsor")).to eql("ponies")
      @magic = "unicorns"
      expect(subject.get_attribute("brooke.winsor")).to eql("unicorns")
    end
  end

  describe "#[]" do
    subject do
      Class.new do
        include VariaModel
        attribute 'foo', default: ->{ String.new("Bacon").upcase }
      end.new
    end

    it "returns the current value of the Proc" do
      expect(subject['foo']).to eql("BACON")
    end

    it "returns the updated value of the Proc" do
      subject['foo']
      subject['foo'] = 'hello'
      expect(subject['foo']).to eql('hello')
    end
  end

  describe "#mass_assign" do
    subject do
      Class.new do
        include VariaModel

        attribute 'brooke.winsor', type: String, default: 'sister'
        attribute 'jamie.winsor', type: String, default: 'brother'
        attribute 'gizmo', type: String, default: 'dog'
      end.new
    end

    it "sets the values of all matching defined attributes" do
      new_attrs = {
        brooke: {
          winsor: "other"
        },
        jamie: {
          winsor: "other_two"
        }
      }

      subject.mass_assign(new_attrs)
      expect(subject.brooke.winsor).to eql("other")
      expect(subject.jamie.winsor).to eql("other_two")
    end

    it "leaves the values of untouched attributes" do
      new_attrs = {
        brooke: {
          winsor: "other"
        },
        jamie: {
          winsor: "other_two"
        }
      }

      subject.mass_assign(new_attrs)
      expect(subject.gizmo).to eql("dog")
    end

    it "ignores values which are not defined attributes" do
      new_attrs = {
        undefined_attribute: "value"
      }

      subject.mass_assign(new_attrs)
      expect(subject.get_attribute(:undefined_attribute)).to be_nil
      expect(subject).not_to respond_to(:undefined_attribute)
    end

    context "when in carefree assignment mode" do
      subject do
        Class.new do
          include VariaModel

          set_assignment_mode :carefree
        end.new
      end

      it "does not ignore values which are not defined" do
        new_attrs = {
          undefined_attribute: "value"
        }

        subject.mass_assign(new_attrs)
        expect(subject.get_attribute(:undefined_attribute)).to eql("value")
      end
    end
  end

  describe "#from_json" do
    subject do
      Class.new do
        include VariaModel

        attribute 'first_name', type: String
        attribute 'nick', type: String
      end.new
    end

    it "returns self" do
      expect(subject.from_json(JSON.dump(first_name: "jamie", nick: "reset"))).to be_a(described_class)
    end

    it "updates self from JSON data" do
      subject.from_json(JSON.dump(first_name: "jamie", nick: "reset"))

      expect(subject.first_name).to eql("jamie")
      expect(subject.nick).to eql("reset")
    end
  end

  describe "#from_hash" do
    subject do
      Class.new do
        include VariaModel

        attribute 'first_name', type: String
        attribute 'nick', type: String
      end.new
    end

    it "returns self" do
      expect(subject.from_hash(first_name: "jamie", nick: "reset")).to be_a(described_class)
    end

    it "updates and returns self from a Hash" do
      subject.from_hash(first_name: "jamie", nick: "reset")

      expect(subject.first_name).to eql("jamie")
      expect(subject.nick).to eql("reset")
    end
  end

  describe "#to_json" do
    class Playa
      include VariaModel

      attribute 'first_name', type: String
      attribute 'nick', type: String
    end

    subject do
      Playa.new
    end

    it "returns a JSON string containin the serialized attributes" do
      subject.first_name = "brooke"
      subject.nick = "leblanc"

      expect(subject.to_json).to eql(JSON.dump(first_name: "brooke", nick: "leblanc", json_class: "Playa"))
    end

    it "includes the most recent value for any Procs" do
      subject.first_name = ->{ "seth".capitalize }
      subject.nick = ->{ "name".upcase }

      expect(subject.to_json).to eql(JSON.dump(first_name: "Seth", nick: "NAME", json_class: "Playa"))
    end

    describe "when JSON.create_id is nil" do
      before do
        @_old_create_id = JSON.create_id
        JSON.create_id = nil
      end

      after do
        JSON.create_id = @_old_create_id
      end

      it "does not include a nil key" do
        subject.first_name = "brooke"
        subject.nick = "leblanc"

        expect(subject.to_json).to eql(JSON.dump(first_name: "brooke", nick: "leblanc"))
      end
    end
  end

  describe "#to_hash" do
    it "returns all of the varia dattributes" do
      expect(subject.to_hash).to eql(subject.send(:_attributes_))
    end
  end
end
