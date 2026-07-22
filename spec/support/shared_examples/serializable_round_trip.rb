# Shared contract for any Games::Serializable PORO: the declared field list
# drives both as_json and from_json, so a dump/load round-trip must not drop or
# alter a single field. Comparing as_json before/after means the including class
# needs no `==`. Round-trips through subject.class so an abstract base can be
# exercised via a concrete stub. Including context must define `subject`.
RSpec.shared_examples "a serializable round-trip" do
  it "restores every field through as_json/from_json" do
    restored = subject.class.from_json(subject.as_json)
    expect(restored.as_json).to eq subject.as_json
  end
end
