require 'rails_helper'

RSpec.describe ApiParamCoordination do
  let(:base_name) { 'base_name' }
  let(:params_hash) do
    [
      {param_one: :text},
      {param_two: :text},
      {param_three: :text},
      {nested_param: [
        {nested_param_one: :text},
        {nested_param_two: :text},
        {nested_param_three: :text},
      ]}
    ]
  end
  let!(:ready) { ApiParamCoordination.(params_hash, base_name) }

  let(:expected_result) do
    [
      {
        name: 'base_name[param_one]',
        title: 'param_one',
        helper: :text_field
      },
      {
        name: 'base_name[param_two]',
        title: 'param_two',
        helper: :text_field
      },
      {
        name: 'base_name[param_three]',
        title: 'param_three',
        helper: :text_field
      },
      {
        name: 'base_name[nested_param][nested_param_one]',
        title: 'nested_param_one',
        helper: :text_field
      },
      {
        name: 'base_name[nested_param][nested_param_two]',
        title: 'nested_param_two',
        helper: :text_field
      },
      {
        name: 'base_name[nested_param][nested_param_three]',
        title: 'nested_param_three',
        helper: :text_field
      },
    ]
  end

  context 'convert_for_form_helper' do
    it { expect(ApiParamCoordination.(params_hash, base_name).converted).to eq(expected_result) }
  end

  context 'method' do
    context 'build_configs' do
      it { expect(ready.convert_each_config(params_hash, base_name)).to eq(expected_result) }
    end

    context 'hash_to_build_config' do
      it { expect(ready.to_build_config({param: :text})).to eq({name: 'param', title: 'param', helper: :text_field}) }
      it { expect(ready.to_build_config({param: :text}, 'base_name')).to eq({name: 'base_name[param]', title: 'param', helper: :text_field}) }
      it { expect(ready.to_build_config({param: :text}, [:a, :b])).to eq({name: 'a[b][param]', title: 'param', helper: :text_field}) }
      it { expect(ready.to_build_config({param: {type: :text, value: 'default'}}, [:a, :b])).to eq({name: 'a[b][param]', title: 'param', helper: :text_field, options: {value: 'default'}}) }
    end

    context 'array_to_name' do
      it { expect(ready.to_name(%w(a b c))).to eq('a[b][c]') }
      it { expect(ready.to_name(%w(a))).to eq('a') }
      it { expect(ready.to_name('a')).to eq('a') }
      it { expect(ready.to_name(:a)).to eq('a') }
    end
  end
end
