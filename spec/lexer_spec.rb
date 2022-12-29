require "stringio"

Text=0
TokenText=1

def pattern2result(text,pattern)
  token_text=text.strip
  pattern.map do |ptn|
    if ptn.equal? Text
      text
    elsif ptn.equal? TokenText
      token_text
    end
    # default nil
  end
end

RSpec.describe Stone do
  describe Stone::Lexer do
    describe "::Pattern" do

      shared_examples "match" do |text,matches|
        match=Stone::Lexer::Pattern.match(text)
        it do
          expect(match).not_to be_nil
          expect(match.to_a.first(matches.size)).to match_array pattern2result(text,matches)
        end
      end

      context "matches blank" do
        include_examples "match", "  ", [Text,nil,nil,nil,nil]
      end
      context "matches comment" do
        include_examples "match", "  //s", [Text,TokenText,TokenText,nil,nil]
      end
      context "matches num" do
        include_examples "match", "  876", [Text,TokenText,nil,TokenText,nil]
      end
      context "matches str" do
        include_examples "match", %q("alpha\\\\"), [Text,Text,nil,nil,Text]
      end
      context "matches name" do
        include_examples "match", "      >", [Text,TokenText,nil,nil,nil]
      end
    end

    describe "#str_literal" do
      lexer=Stone::Lexer.new StringIO.new

      it "gets literal" do
        expect(lexer.str_literal %q("\n")).to eq ?\n
        expect(lexer.str_literal %q("\\\\")).to eq ?\\
        expect(lexer.str_literal %q("\"")).to eq ?"
      end
    end

    describe "#add_token" do
      line_no=0
      # lexer=Stone::Lexer.new StringIO.new
      let(:lexer) { @lexer }
      before { @lexer=Stone::Lexer.new StringIO.new}

      shared_examples "nothing" do
        it "adds nothing" do
          lexer.add_token line_no, matches
          expect(lexer.queue).to be_empty
        end
      end

      shared_examples "token" do |klass,name,val|
        it "adds a #{klass.name}" do
          lexer.add_token line_no, matches
          token=lexer.queue.last
          expect(token).to be_a klass
          expect(token.send name).to eq val
        end
      end

      context "when blank" do
        let(:matches) { pattern2result("   ", [Text,nil,nil,nil,nil]) }
        # lexer.add_token line_no, pattern2result("   ", [Text,nil,nil,nil,nil])
        include_examples "nothing"
      end
      
      context "when comment" do
        let(:matches) { pattern2result("//nice", [Text,Text,Text,nil,nil]) }
        # lexer.add_token line_no, pattern2result("//nice", [Text,Text,Text,nil,nil])
        include_examples "nothing"
      end

      context "when num" do
        let(:matches) { pattern2result("  3842", [Text,TokenText,nil,TokenText,nil]) }
        include_examples "token",Stone::NumToken,:num,3842
      end

      context "when str" do
        let(:matches) { pattern2result(%q("gamma\\\\"), [Text,Text,nil,nil,Text]) }
        include_examples "token",Stone::StrToken,:str,"gamma\\"
      end

      context "when name" do
        let(:matches) { pattern2result("&&", [Text,Text,nil,nil,nil]) }
        include_examples "token",Stone::NameToken,:name,"&&"
      end
    end

    describe "#read" do
      let(:script) do
        text=[
          %q(a = 3;),
          %q(b="\n"),
          "",
          %q(a + b)
        ].join "\n"
        StringIO.new text
      end
      tokens="a=3;\nb=\n\n\na+b\n".each_char.to_a
      it "reads tokens" do
        lexer=Stone::Lexer.new script
        until (token=lexer.read).eql? Stone::Token::EOF
          expect(token.str).to eq tokens.shift
        end
      end
    end
  end
end
