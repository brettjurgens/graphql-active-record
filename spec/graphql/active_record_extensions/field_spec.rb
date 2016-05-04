require 'spec_helper'

RSpec.describe GraphQL::ActiveRecordExtensions::Field do
  let(:customer_id)   { Customer.first.id }
  let(:customer_uuid) { Customer.first.uuid }
  let(:product_id)    { Product.first.id }

  describe 'includes' do
    let(:query_str) do
      <<-GQL
      query {
        customer(id: "#{customer_id}") {
          product {
            id
          }
        }
      }
      GQL
    end

    it "works" do
      expect_any_instance_of(GraphQL::ActiveRecordExtensions::Field)
        .to receive(:include_in_model)
        .with(Customer, ['product'])
        .and_call_original

      result = query(query_str)
      expect(result['data']['customer']['product']['id'].to_i).to eq(product_id)
    end

    it "ignores bad includes" do
      expect_any_instance_of(GraphQL::ActiveRecordExtensions::Field)
        .to receive(:include_in_model)
        .with(Customer, ['product'])
        .and_return(Customer.includes(:fake_model))

      result = query(query_str)
      expect(result['data']['customer']['product']['id'].to_i).to eq(product_id)
    end
  end

  describe 'no includes' do
    let(:query_str) do
      <<-GQL
      query {
        customer(id: "#{customer_id}") {
          id
        }
      }
      GQL
    end

    it "doesn't include" do
      expect_any_instance_of(GraphQL::ActiveRecordExtensions::Field)
        .to receive(:include_in_model)
        .with(Customer, [])
        .and_call_original

      result = query(query_str)
      expect(result['data']['customer']['id'].to_i).to eq(customer_id)
    end
  end

  describe 'with uuid' do
    let(:query_str) do
      <<-GQL
      query {
        customer(id: "#{customer_uuid}", use_uuid: true) {
          id
        }
      }
      GQL
    end

    it "finds by uuid" do
      expect(Customer)
        .to receive(:find_by_uuid)
        .with(customer_uuid)
        .and_call_original

      result = query(query_str)
      expect(result['data']['customer']['id'].to_i).to eq(customer_id)
    end

  end
end
