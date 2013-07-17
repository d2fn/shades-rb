require 'spec_helper'
require 'ostruct'

module Shades
  describe QueryParser do
    it "parses rollups out of the query expression" do
      query = QueryParser.parse("sum(amount) by transactionid", OpenStruct)

      expect(query.rollups.length).to eq(1)
      expect(query.rollups[0][:measure]).to eq("amount")
      expect(query.rollups[0][:stat]).to eq(Stats::SUM)
    end

    it "parses multiple rollups out of the query expression" do
      query = QueryParser.parse("sum(amount), max(quantity) by transactionid", OpenStruct)

      expect(query.rollups.length).to eq(2)
      expect(query.rollups[0][:measure]).to eq("amount")
      expect(query.rollups[1][:measure]).to eq("quantity")
    end

    it "parses categorizations out of the query expression" do
      query = QueryParser.parse("sum(amount) by transactionid", OpenStruct)
      expect(query.categorizations).to eq(["transactionid"])
    end

    it "parses multiple categorizations out of the query expression" do
      query = QueryParser.parse("sum(amount) by customer, item", OpenStruct)
      expect(query.categorizations).to eq(["customer", "item"])
    end

    it "parses sort descriptions out of the query expression" do
      query = QueryParser.parse("sum(amount) by transactionid order by amount", OpenStruct)

      expect(query.sorting.length).to eq(1)
      expect(query.sorting[0][:key]).to eq("amount")
      expect(query.sorting[0][:asc]).to eq(true)
    end

    it "parses multiple sort descriptions out of the query expression" do
      query = QueryParser.parse("sum(amount) by transactionid order by amount, customerid", OpenStruct)

      expect(query.sorting.length).to eq(2)
      expect(query.sorting[0][:key]).to eq("amount")
      expect(query.sorting[1][:key]).to eq("customerid")
    end
  end
end
