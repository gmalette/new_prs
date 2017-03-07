require "spec_helper"

describe NewPrs::CLI::Menu do
  let(:root_command_stub) { double("Command Stub") }
  let(:object_command_stub_1) { double("Object Command Stub 1") }
  let(:object_command_stub_2) { double("Object Command Stub 2") }
  let(:cli) { double("HighLine") }
  let(:objects) do
    [
      ["Item 1", described_class.new(cli).command("t", "touch") { object_command_stub_1.touch }],
      ["Item 2", described_class.new(cli).command("t", "touch") { object_command_stub_2.touch }],
    ]
  end

  before do
    allow(cli).to(receive(:say).and_return(""))
  end

  subject do
    described_class.new(cli)
      .command("q", "Quit") { stub.quit }
      .list(objects, all: "a", each: "e")
  end

  describe "#run" do
    it "displays the menu" do
      expected = Regexp.new(Regexp.escape("1. Item 1\n2. Item 2\na. All\nq. Quit"))
      expect(cli).to(receive(:say).with(expected))
      allow(cli).to(receive(:ask).and_return(""))
      subject.run
    end

    it "buffers commands for lists" do
      expect(object_command_stub_1).to(receive(:touch))
      allow(cli).to(receive(:ask).and_return("1t", ""))

      subject.run
    end

    it "enumerates through lists via all" do
      expect(object_command_stub_1).to(receive(:touch))
      expect(object_command_stub_2).to(receive(:touch))
      allow(cli).to(receive(:ask).and_return("at", ""))

      subject.run
    end

    it "can receive multiple messages" do
      expect(object_command_stub_1).to(receive(:touch).twice)
      allow(cli).to(receive(:ask).and_return("1tt", ""))
      subject.run
    end

    it "can retrieve lists from procs" do
      stub = double("Stub")
      allow(cli).to(receive(:ask).and_return(""))
      expect(stub).to(receive(:touch))
      list = [["first item", described_class.new(cli).command("t", "touch") { stub.touch }]]
      described_class.new(cli).list(-> { list }).run(["1", "t"])
    end

    it "enumerates through lists via each"
  end
end
