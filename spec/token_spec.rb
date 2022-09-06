
RSpec.describe Stone do
  describe Stone::Token do
    let(:others){ Stone::Token.new(-1) }
    describe "#num" do
      it "raises StoneError" do
        expect {others.num}.to raise_error Stone::StoneError
      end
    end
    describe "::EOF" do
      subject { Stone::Token::EOF }
      it "exists" do
        is_expected.not_to be nil
        is_expected.to be_a Stone::Token
      end
    
      it "only equals to itself" do
        is_expected.to eql subject
        is_expected.not_to eql others
        is_expected.not_to equal others
      end
    end
  end

  let(:line_no) { 0 }
  describe Stone::NumToken do
    let(:num) { 42 }
    let(:token) { Stone::NumToken.new line_no,num }
    it "has num" do
      expect(token.num).to eq num
      expect(token.str.to_i).to eq num
    end
  end

  describe Stone::NameToken do
    let(:name) { "for" }
    let(:token) { Stone::NameToken.new line_no,name }
    it "has name" do
      expect(token.name).to eq token.str
    end
  end

  describe Stone::StrToken do
    let(:str) { %q("\n") }
    let(:token) { Stone::StrToken.new line_no,str }
    it "has str" do
      expect(token.str).to eq str
    end
  end
end

