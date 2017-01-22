require "spec_helper"

describe NewPrs::Actions::FetchPullRequests do
  describe ":fetch_pull_requests" do
    it "queries Github with the options and yields results" do
      node = double
      cursor = double
      edges = [double(node: node, cursor: cursor)]
      stub_graphql_fetch(pages: [edges])

      expect do |block|
        described_class.fetch_pull_requests(owner: "Shopify", name: "shopify", &block)
      end.to(yield_with_args(node, cursor))
    end

    it "queries Github in a loop if there are more pages" do
      pages = [
        [double(node: double, cursor: double)],
        [double(node: double, cursor: double)],
      ]
      stub_graphql_fetch(pages: pages)

      expect do |block|
        described_class.fetch_pull_requests(owner: "Shopify", name: "shopify", &block)
      end.to(yield_control.twice)
    end
  end

  private

  def stub_graphql_fetch(pages:)
    responses = pages.map do |edges|
      page_info = double(hasNextPage: edges != pages.last)
      double(data: double(repository: double(pullRequests: double(edges: edges, pageInfo: page_info))))
    end

    expect(NewPrs::GithubClient)
      .to(receive(:query))
      .with(
        NewPrs::Actions::FetchPullRequests::Query,
        variables: { owner: "Shopify", name: "shopify", after: anything },
      )
      .and_return(*responses)
  end
end
