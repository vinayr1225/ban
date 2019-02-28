# frozen_string_literal: true

require 'spec_helper'

describe Banzai::Filter::SuggestionFilter do
  include FilterSpecHelper

  let(:input) { "<pre class='code highlight js-syntax-highlight suggestion'><code>foo\n</code></pre>" }
  let(:default_context) do
    { suggestions_filter_enabled: true }
  end

  it 'includes `js-render-suggestion` class' do
    doc = filter(input, default_context)
    result = doc.css('code').first

    expect(result[:class]).to include('js-render-suggestion')
  end

  it 'includes no `js-render-suggestion` when filter is disabled' do
    doc = filter(input)
    result = doc.css('code').first

    expect(result[:class]).to be_nil
  end

  context 'when suggestion params' do
    let(:input) do
      "<pre class='code highlight js-syntax-highlight suggestion' lang='suggestion' lang-params=#{lang_param}><code>foo\n</code></pre>"
    end

    context 'only above' do
      let(:lang_param) { '-1' }

      it 'includes correct data-lines-above' do
        doc = filter(input, default_context)
        code = doc.css('code').first

        expect(code['data-lines-above']).to eq('-1')
        expect(code['data-lines-below']).to eq('0')
      end
    end

    context 'only below' do
      let(:lang_param) { '+10' }

      it 'includes correct data-lines-below' do
        doc = filter(input, default_context)
        code = doc.css('code').first

        expect(code['data-lines-above']).to eq('0')
        expect(code['data-lines-below']).to eq('10')
      end
    end

    context 'above and below' do
      let(:lang_param) { '-1+3' }

      it 'includes correct data-lines-above and data-lines-below' do
        doc = filter(input, default_context)
        code = doc.css('code').first

        expect(code['data-lines-above']).to eq('-1')
        expect(code['data-lines-below']).to eq('3')
      end
    end

    context 'invalid argument' do
      let(:lang_param) { '+1+1-3' }

      it 'does not change data-lines-above or data-lines-below' do
        doc = filter(input, default_context)
        code = doc.css('code').first

        expect(code['data-lines-above']).to be_nil
        expect(code['data-lines-below']).to be_nil
      end
    end
  end
end
