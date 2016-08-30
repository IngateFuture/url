describe Url do
  let(:string) { 'lenta.ru' }
  let(:url) { Url.new string }

  describe '#assign' do
    subject { url.assign(hash).to_s }

    let(:hash) { { p1: 'p1', 'p2' => 'p2' } }

    context 'link has params' do
      let(:string) { 'http://test.org/test?p3=p3' }
      it { is_expected.to eq 'http://test.org/test?p3=p3&p1=p1&p2=p2' }
    end

    context 'link without params' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end

    context 'link with the same params' do
      let(:string) { 'http://test.org/test?p1=p1' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end

    context 'passed params overwrites query string' do
      let(:string) { 'http://test.org/test?p1=pppp1' }
      it { is_expected.to eq 'http://test.org/test?p1=p1&p2=p2' }
    end

    context 'not escaped param' do
      let(:hash) { { 'p2' => '[]' } }
      let(:string) { 'http://test.org/test?p1=pppp1' }
      it { is_expected.to eq 'http://test.org/test?p1=pppp1&p2=[]' }
    end

    context 'not string param' do
      let(:hash) { { 'p2' => [] } }
      let(:string) { 'http://test.org/test?p1=pppp1' }
      it { expect { subject }.to raise_error ArgumentError }
    end
  end

  describe '#[]' do
    subject { url[param_name] }
    let(:string) { 'http://test.org/test?p1=p1&p2=p2' }

    context 'param exists' do
      let(:param_name) { :p1 }
      it { is_expected.to be_truthy }
    end

    context "param doesn't exist" do
      let(:param_name) { :p3 }
      it { is_expected.to be_falsy }
    end

    context 'no params' do
      let(:string) { 'http://test.org/test' }
      let(:param_name) { :p3 }

      it { is_expected.to be_falsy }
    end
  end

  describe '#with_http' do
    subject { url.with_http.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'http://test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'http://test.org' }
    end
  end

  describe 'without_http' do
    subject { url.without_http.to_s }

    context 'has_http' do
      let(:string) { 'http://test.org' }
      it { is_expected.to eq 'test.org' }
    end

    context 'no_http' do
      let(:string) { 'test.org' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#extract_domain' do
    subject { url.domain.to_s }

    context 'with www' do
      let(:string) { 'http://www.test.org/test' }
      it { is_expected.to eq 'www.test.org' }
    end

    context 'without www' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'test.org' }
    end

    context 'get params' do
      let(:string) { 'http://test.org?zz=1' }
      it { is_expected.to eq 'test.org' }
    end
  end

  describe '#cut_www' do
    subject { url.cut_www.to_s }

    context 'with www' do
      context 'with protocol' do
        let(:string) { 'http://www.test.org/test' }
        it { is_expected.to eq 'http://test.org/test' }
      end

      context 'without protocol' do
        let(:string) { 'www.test.org/test' }
        it { is_expected.to eq 'test.org/test' }
      end
    end

    context 'without www' do
      let(:string) { 'http://test.org/test' }
      it { is_expected.to eq 'http://test.org/test' }
    end
  end

  describe '#punycode' do
    subject { url.punycode.to_s }

    context 'punycoded' do
      let(:string) { 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
      it { is_expected.to eq 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
    end

    context 'url_with_port' do
      let(:string) { 'http://овд-арзамас.рф:8080' }
      it { is_expected.to eq 'http://xn----8sbaagmx5blyp.xn--p1ai:8080' }
    end

    context 'russian_url' do
      let(:string) { 'http://дайвинг.аква-эко.рф/test' }
      it { is_expected.to eq 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
    end

    context 'normal_url' do
      let(:string) { 'http://test.ru/test' }
      it { is_expected.to eq 'http://test.ru/test' }
    end

    context 'url with get params w/o slash' do
      let(:string) { 'https://github.com?dfg=dfgd&dsfg=dfg' }
      it { is_expected.to eq 'https://github.com?dfg=dfgd&dsfg=dfg' }
    end
  end

  describe '#depunycode' do
    subject { url.depunycode.to_s }

    context 'punycoded' do
      let(:string) { 'http://xn--80aedbwe4a.xn----7sbah3bd2a2j.xn--p1ai/test' }
      it { is_expected.to eq 'http://дайвинг.аква-эко.рф/test' }
    end

    context 'punycoded with dot' do
      let(:string) { 'http://xn----htbyhhgt.xn--p1ai/effektivnyy-sayt-kompanii.' }
      it { is_expected.to eq 'http://фрс-дом.рф/effektivnyy-sayt-kompanii.' }
    end

    context 'punycoded with port' do
      let(:string) { 'xn----8sbaagmx5blyp.xn--p1ai:8080' }
      it { is_expected.to eq 'овд-арзамас.рф:8080' }
    end

    context 'russian url' do
      let(:string) { 'http://дайвинг.аква-эко.рф/test' }
      it { is_expected.to eq 'http://дайвинг.аква-эко.рф/test' }
    end

    context 'normal url' do
      let(:string) { 'http://test.ru/test' }
      it { is_expected.to eq 'http://test.ru/test' }
    end

    context 'root url' do
      let(:string) { 'http://test.ru/' }
      it { is_expected.to eq 'http://test.ru/' }
    end

    context 'raw domain' do
      let(:string) { 'zxc.ru' }
      it { is_expected.to eq 'zxc.ru' }
    end

    context 'malformed punycode' do
      let(:string) { 'http://xn--80amkfe6bh3.ucoz.ru/' }
      it { is_expected.to eq string }
    end
  end
end
