# frozen_string_literal: true

RSpec.describe HCloud::Resource do
  subject(:resource) { resource_class.new }

  let(:resource_class) do
    Class.new(described_class) do
      attribute :id, :integer
      attribute :name
      attribute :description

      attribute :labels, default: -> { {} }

      attribute :created, :datetime

      def creatable_attributes
        [:name, :description, :labels]
      end

      def updatable_attributes
        [:name, :description, :labels]
      end

      # Override resource name
      def self.resource_name
        "resource"
      end
    end
  end

  it "has default labels" do
    expect(resource_class.new.labels).to eq({})
  end

  describe "#create" do
    subject(:resource) { resource_class.new(id: nil, created: nil) }

    it "creates the resource" do
      stub_request(:post, "https://api.hetzner.cloud/v1/resources")
        .with(body: resource.attributes.slice(*resource.creatable_attributes.map(&:to_s)))
        .to_return(body: { resource: resource.attributes.merge(id: 1, created: 1.second.ago) }.to_json)

      resource.create

      expect(resource.id).to eq 1
      expect(resource).to be_created
    end
  end

  describe "#update" do
    it "updates the resource" do
      stub_request(:put, "https://api.hetzner.cloud/v1/resources/#{resource.id}")
        .with(body: resource.attributes.slice(*resource.updatable_attributes.map(&:to_s)))
        .to_return(body: { resource: resource.attributes.merge(name: "my_name") }.to_json)

      resource.update

      expect(resource.name).to eq "my_name"
    end
  end

  describe "#delete" do
    it "deletes the resource" do
      stub_request(:delete, "https://api.hetzner.cloud/v1/resources/#{resource.id}")
        .to_return(body: {}.to_json)

      resource.delete

      expect(resource).to be_deleted
    end
  end

  describe ".find" do
    it "returns an instance of the resource" do
      stub_request(:get, "https://api.hetzner.cloud/v1/resources/#{resource.id}")
        .to_return(body: { resource: resource.attributes }.to_json)

      model = resource_class.find(resource.id)

      expect(model).to be_a described_class
      expect(model.attributes).to eq resource.attributes
    end
  end

  describe ".all" do
    it "returns resources" do
      stub_request(:get, "https://api.hetzner.cloud/v1/resources")
        .with(query: { page: 1, per_page: 50 })
        .to_return(body: { resources: [resource.attributes], meta: { pagination: { total_entries: 1 } } }.to_json)

      models = resource_class.all

      expect(models.count).to eq 1
      expect(models.first).to be_a resource_class
      expect(models.first.attributes).to eq resource.attributes
    end

    it "returns resources sorted by name" do
      stub_request(:get, "https://api.hetzner.cloud/v1/resources")
        .with(query: { page: 1, per_page: 50, sort: "name:desc" })
        .to_return(body: { resources: [resource.attributes.merge(id: 1, name: "aaa"), resource.attributes.merge(id: 2, name: "bbb")], meta: { pagination: { page: 1, last_page: 1, total_entries: 2 } } }.to_json)

      models = resource_class.all.sort(name: :desc)

      expect(models.count).to eq 2
      expect(models.map(&:id)).to eq [1, 2]
    end

    it "returns resources filtered by name" do
      stub_request(:get, "https://api.hetzner.cloud/v1/resources")
        .with(query: { page: 1, per_page: 50, name: "aaa" })
        .to_return(body: { resources: [resource.attributes.merge(id: 1, name: "aaa")], meta: { pagination: { total_entries: 1 } } }.to_json)

      models = resource_class.all.where(name: "aaa")

      expect(models.count).to eq 1
    end
  end
end