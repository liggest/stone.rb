
def io_error
  File.open(__FILE__) {|f| f.close; f.read }
rescue IOError => e
  return e
end

RSpec.describe Stone do
  let(:msg) { "opps" }
  describe Stone::StoneError do
    context "has message" do
      let(:error) { Stone::StoneError.new msg}
      it { expect(error.message).to eq msg }
    end
    context "receives AST" do
      let(:location) { 0 }
      let(:error) { Stone::StoneError.new msg,Stone::AST::Leaf.new(Stone::NameToken.new(location,"x"))  }
      # skip "AST not implemented"
      it { expect(error.message).to eq %Q(#{msg} [Line #{location}]) }
    end
  end

  describe Stone::ParseError do
    let(:line_no){ 5 }
    let(:token) { Stone::NameToken.new line_no,msg }
    context "receives String" do
      let(:error) { Stone::ParseError.new msg}
      it { expect(error.message).to eq msg }
    end
    context "receives IOError" do
      io_err=io_error
      let(:error) { Stone::ParseError.new io_err }
      it { expect(error.message).to eq io_err.message }
    end
    context "receives String and Token" do
      let(:error) { Stone::ParseError.new msg,token }
      it { expect(error.message).to eq %Q(syntax error around "#{token.str}" at line #{token.line_no}. #{msg}) }
    end
    context "receives Token" do
      let(:error) { Stone::ParseError.new Stone::Token::EOF }
      it { expect(error.message).to eq %Q(syntax error around the last line. ) }
    end
  end
end
